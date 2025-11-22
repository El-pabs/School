# 🛰️ **DOCUMENTATION : FreeRADIUS + AAA Cisco Switch (Agence 08)**

---

## **1. Objectif**

- Centraliser l'authentification des **administrateurs switch Cisco** sur un serveur **FreeRADIUS**
- Gérer les **droits d'accès** (admin/opérateur/support) via **privilege levels Cisco**
- Permettre l'**accès SSH/Telnet/Console** au Catalyst 2960+ avec contrôle AAA
- Intégration **simultanée** avec FortiGate pour authentification unifiée

---

## **2. Topologie**

```
┌─────────────────────────────────────────────────────────────────┐
│                    LAN AGENCE 08 (172.27.50.0/24)              │
│                                                                  │
│  [Admin PC]           [FortiGate]         [Catalyst 2960+]     │
│  (SSH/Telnet)      172.27.50.1           172.27.50.70          │
│                                                                  │
│                    ↓ RADIUS ↑                                  │
│                                                                  │
│              [Linux FreeRADIUS Server]                         │
│              (Port 1812/1813 UDP)                              │
└─────────────────────────────────────────────────────────────────┘

Flux : Admin SSH → Switch → Demande RADIUS → FreeRADIUS
       → Vérifie user/pass + priv-level → Retour ACL
```

---

## **3. Architecture AAA Cisco**

```
┌─────────────────────────────────────────────┐
│     AUTHENTIFICATION (username/password)     │
│   (RADIUS demande identité à FreeRADIUS)    │
└────────────────┬────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────┐
│    AUTORISATION (privilege level)            │
│  (RADIUS retourne shell:priv-lvl=15/7/1)    │
└────────────────┬────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────┐
│    ACCOUNTING (logs des connexions)          │
│   (Switch log toutes les connexions RADIUS) │
└─────────────────────────────────────────────┘
```

---

## **4. Installation FreeRADIUS + Configuration Clients**

### **Étape 1 : Télécharge et exécute le script**

**Créer le fichier `setup-radius-aaa.sh` :**

```bash
nano setup-radius-aaa.sh
```

**Copie-colle le script complet ci-dessous :**

```bash
#!/bin/bash

### ===== INFORMATIONS DE BASE ===== ###
RADIUS_SECRET="SuperSecretRadius2025!"
RADIUS_SERVER_IP=$(hostname -I | awk '{print $1}')
FG_IP="172.27.50.1"
SWITCH_IP="172.27.50.70"

# Utilisateurs RADIUS
USER_ADMIN="admin"
PWD_ADMIN="AdminPassword123"
USER_OPERATOR="operator"
PWD_OPERATOR="OperatorPass789"
USER_SUPPORT="support"
PWD_SUPPORT="SupportPass102"

cat << "EOF"
╔═════════════════════════════════════════════════════════════════╗
║   FreeRADIUS + AAA (FortiGate + Cisco Switch / Agence 08)     ║
╚═════════════════════════════════════════════════════════════════╝
EOF

set -e

echo "
🛠️  Étape 1 : Installation/Update des paquets nécessaires...
"
sudo dnf update -y
sudo dnf install -y freeradius freeradius-utils

echo "
📂 Étape 2 : Certificats EAP (génération)
"
cd /etc/raddb/certs/
sudo make clean > /dev/null 2>&1 || true
sudo ./bootstrap > /dev/null 2>&1 || true

echo "
⚙️  Étape 3 : Configuration des CLIENTS RADIUS (FortiGate + Switch + Local)
"
sudo tee /etc/raddb/clients.conf > /dev/null <<'EOF_CLIENTS'
# ===== FORTIGATE AG008 =====
client fortigate-agence08 {
    ipaddr = 172.27.50.1
    secret = SuperSecretRadius2025!
    shortname = fortigate-agence08
    nas_type = fortinet
}

# ===== SWITCH CISCO CATALYST 2960+ (AAA) =====
client switch-core {
    ipaddr = 172.27.50.70
    secret = SuperSecretRadius2025!
    shortname = switch-core
    nas_type = cisco
}

# ===== LOCALHOST (Tests locaux) =====
client localhost {
    ipaddr = 127.0.0.1
    secret = testing123
    shortname = localhost
}
EOF_CLIENTS

echo "
🔑 Étape 4 : Configuration des UTILISATEURS + PRIVILEGE LEVELS Cisco
"
sudo tee /etc/raddb/users > /dev/null <<'EOF_USERS'
# ===== ADMINISTRATEUR (Privilege Level 15 = Full Access) =====
admin Cleartext-Password := "AdminPassword123"
    Service-Type = NAS-Prompt-User,
    Cisco-AVPair = "shell:priv-lvl=15",
    Reply-Message = "Bienvenue Administrateur RADIUS"

# ===== OPÉRATEUR (Privilege Level 7 = Monitoring + Some Commands) =====
operator Cleartext-Password := "OperatorPass789"
    Service-Type = NAS-Prompt-User,
    Cisco-AVPair = "shell:priv-lvl=7",
    Reply-Message = "Bienvenue Opérateur RADIUS"

# ===== SUPPORT (Privilege Level 1 = Read-Only) =====
support Cleartext-Password := "SupportPass102"
    Service-Type = NAS-Prompt-User,
    Cisco-AVPair = "shell:priv-lvl=1",
    Reply-Message = "Bienvenue Support RADIUS"

# ===== DEFAULT : REFUS =====
DEFAULT Auth-Type := Reject
    Reply-Message = "Accès RADIUS refusé - Utilisateur non autorisé"
EOF_USERS

sudo chown -R radiusd:radiusd /etc/raddb/

echo "
🚦 Étape 5 : Activation & Démarrage du service FreeRADIUS
"
sudo systemctl enable radiusd
sudo systemctl restart radiusd

sleep 2

echo "
🐾 Étape 6 : Test local (authentication test)
"
radtest admin AdminPassword123 localhost 1812 testing123

echo "
📡 Étape 7 : Configuration du Firewall (ouvrir ports RADIUS)
"
sudo firewall-cmd --add-port=1812/udp --permanent
sudo firewall-cmd --add-port=1813/udp --permanent
sudo firewall-cmd --reload

echo "
✅ FREERADIUS CONFIGURÉ AVEC SUCCÈS

╔═════════════════════════════════════════════════════════════════╗
║                        RÉSUMÉ INSTALLATION                      ║
╚═════════════════════════════════════════════════════════════════╝

📡 SERVEUR RADIUS :
   IP             : $RADIUS_SERVER_IP
   Port Auth      : 1812/UDP
   Port Acct      : 1813/UDP
   Secret         : SuperSecretRadius2025!

🔌 CLIENTS CONFIGURÉS :
   → FortiGate    : 172.27.50.1
   → Switch Cisco : 172.27.50.70
   → Localhost    : 127.0.0.1

👥 UTILISATEURS RADIUS :
   → admin        : AdminPassword123      (Priv Level 15)
   → operator     : OperatorPass789       (Priv Level 7)
   → support      : SupportPass102        (Priv Level 1)

✔️  SERVICE RADIUSD : actif et en écoute
✔️  FIREWALL OUVERT : ports 1812/1813 UDP autorisés

╔═════════════════════════════════════════════════════════════════╗
║         PROCHAINE ÉTAPE : CONFIGURER LE SWITCH CISCO           ║
╚═════════════════════════════════════════════════════════════════╝
"
```

**Sauvegarde et exécute :**

```bash
chmod +x setup-radius-aaa.sh
sudo ./setup-radius-aaa.sh
```

---

## **5. Configuration AAA du Switch Cisco Catalyst 2960+**

### **Étape 1 : Connexion au switch**

```bash
ssh admini@172.27.50.70
# ou via console série
```

### **Étape 2 : Configuration CLI (copie-colle l'intégralité)**

```shell
enable
configure terminal

# ===== 1. DÉCLARATION DU SERVEUR RADIUS =====
radius server RADIUS-AG08
    address ipv4 172.27.50.1 auth-port 1812 acct-port 1813
    key SuperSecretRadius2025!
    timeout 5
    retransmit 3
exit

# ===== 2. ACTIVATION AAA (nouveau modèle) =====
aaa new-model

# ===== 3. CRÉATION DU GROUPE RADIUS =====
aaa group server radius GROUPE-RADIUS-AG08
    server name RADIUS-AG08
exit

# ===== 4. AUTHENTIFICATION (SSH/Telnet/Console) =====
# Priorité : RADIUS d'abord, fallback LOCAL
aaa authentication login default group GROUPE-RADIUS-AG08 local
aaa authentication login console group GROUPE-RADIUS-AG08 local
aaa authentication enable default group GROUPE-RADIUS-AG08 enable

# ===== 5. AUTORISATION (basée sur priv-lvl RADIUS) =====
aaa authorization commands 0 default group GROUPE-RADIUS-AG08 local
aaa authorization commands 1 default group GROUPE-RADIUS-AG08 local
aaa authorization commands 15 default group GROUPE-RADIUS-AG08 local

# ===== 6. ACCOUNTING (traçabilité) =====
aaa accounting exec default start-stop group GROUPE-RADIUS-AG08
aaa accounting commands 0 default start-stop group GROUPE-RADIUS-AG08
aaa accounting commands 1 default start-stop group GROUPE-RADIUS-AG08
aaa accounting commands 15 default start-stop group GROUPE-RADIUS-AG08

# ===== 7. CONFIGURATION DES LIGNES (VTY + Console) =====
line con 0
    login authentication console
    logging synchronous
exit

line vty 0 4
    login authentication default
    logging synchronous
    transport input ssh telnet
exit

# ===== 8. CONFIGURATION SSH (sécurité) =====
ip ssh authentication retries 3
ip ssh time-out 120
ip ssh version 2

# ===== SAUVEGARDE =====
end
write memory
```

---

## **6. Vérification & Tests**

### **Test 1 : Vérification du service RADIUS (serveur)**

```bash
# Sur le serveur RADIUS
sudo systemctl status radiusd

# Vérifier les logs en temps réel
sudo tail -f /var/log/radius/radius.log
```

### **Test 2 : Test RADIUS local (avant de tester sur switch)**

```bash
# Test authentification admin
radtest admin AdminPassword123 localhost 1812 testing123

# Test authentification operator
radtest operator OperatorPass789 localhost 1812 testing123

# Test authentification support
radtest support SupportPass102 localhost 1812 testing123

# Les 3 doivent retourner : "Access-Accept" (pas "Access-Reject")
```

### **Test 3 : SSH au switch avec compte RADIUS (admin)**

```bash
# Depuis une autre machine
ssh admin@172.27.50.70

# À l'invite, entre : AdminPassword123
# Puis commande :
show privilege
# Doit afficher : "Current privilege level is 15"
```

### **Test 4 : SSH avec compte RADIUS (operator)**

```bash
ssh operator@172.27.50.70
# Password: OperatorPass789
show privilege
# Doit afficher : "Current privilege level is 7"
```

### **Test 5 : SSH avec compte RADIUS (support)**

```bash
ssh support@172.27.50.70
# Password: SupportPass102
show privilege
# Doit afficher : "Current privilege level is 1"
```

### **Test 6 : Vérifier l'accounting (logs des connexions)**

```bash
# Sur le switch
show accounting commands

# Doit afficher historique des connexions RADIUS avec timestamps
```

---

## **7. Tableau Résumé : Privilege Levels & Permissions**

| Utilisateur | Mot de passe | Priv Level | Accès SSH | Accès Console | Commands autorisés |
|-------------|--------------|-----------|-----------|---------------|--------------------|
| **admin** | AdminPassword123 | 15 | ✅ Oui | ✅ Oui | ALL (config + shutdown) |
| **operator** | OperatorPass789 | 7 | ✅ Oui | ✅ Oui | Monitoring + show cmds |
| **support** | SupportPass102 | 1 | ✅ Oui | ✅ Oui | Show cmds (read-only) |
| Autre user | N/A | 0 | ❌ Non | ❌ Non | Aucun |

---

## **8. Fallback LOCAL (Compte de secours)**

⚠️ **IMPORTANT** : Si RADIUS est indisponible, tu peux toujours te connecter avec le compte **local admini** :

```bash
ssh admini@172.27.50.70
# Authentification locale (hors RADIUS)
show privilege
# Priv level 15 (compte local)
```

**Pour garder ce fallback de secours :**

```bash
# Sur le switch, reste connecté en tant que admini local
# Ajoute une vérification :
show running-config | include username
# Doit afficher : "username admini privilege 15 secret ..."

# Si ce compte est parti, le recréer :
enable
configure terminal
username admini privilege 15 secret EmergencyBackupPass2025!
end
write memory
```

---

## **9. Dépannage Avancé**

### **Problème : RADIUS refusé (Access-Reject)**

```bash
# Sur serveur RADIUS, vérifie les logs
sudo tail -50 /var/log/radius/radius.log | grep admin

# Cherche "Access-Reject" + raison
# Solutions :
# 1. Mauvais mot de passe utilisateur
# 2. Mauvais secret RADIUS (doit être identique côté switch)
# 3. Utilisateur mal déclaré dans /etc/raddb/users
```

### **Problème : "Connection timeout" SSH au switch**

```bash
# Sur le switch, vérifie la connectivité RADIUS
ping 172.27.50.1

# Depuis RADIUS, teste "reverse"
ping 172.27.50.70

# Vérifies le firewall switch (ACL)
show ip access-lists
# Doit autoriser trafic UDP 1812/1813 vers RADIUS
```

### **Problème : Priv level correct (15) mais pas tous les commands**

```bash
# Le switch a peut-être des command authorization policies
# Affiche :
show running-config | include aaa authorization

# Le priv-level 15 devrait débloquer toutes les commandes
# Si ce n'est pas le cas, ajoute :
no aaa authorization commands 15
```

### **Problème : Utilisateur RADIUS marche mais pas de backup local**

```bash
# Sécurité : Garde TOUJOURS un compte local en backup
enable
configure terminal
username admin-local privilege 15 secret BackupAdminPass123!
end
write memory

# Maintenant tu peux te connecter localement même sans RADIUS
ssh admin-local@172.27.50.70
```

---

## **10. FortiGate + Cisco Switch : Configuration unifiée**

### **Sur FortiGate (même RADIUS)**

```shell
config user radius
    edit "RADIUS_AG08"
        set server 172.27.50.1
        set secret SuperSecretRadius2025!
        set source-ip 172.27.50.1
        set authentication pap
    next
end

config user group
    edit "Admins-RADIUS"
        set member "RADIUS_AG08"
    next
end
```

### **Sur Cisco Switch**

```shell
# Déjà configuré plus haut (voir étape 5)
```

✅ **Résultat** : Admin RADIUS = accès centralisé FortiGate + Switch Cisco

---

## **11. Sécurité en Production**

### **Recommandation 1 : Chiffrer les mots de passe RADIUS**

Au lieu de `Cleartext-Password`, utilise **MD5-Password** :

```bash
# Génère hash MD5
echo -n "AdminPassword123" | md5sum
# Résultat : 0f1d5f8a5d7d5d5f5d5f8a5d7d5d5f5f (exemple)

# Dans /etc/raddb/users :
admin MD5-Password := 0f1d5f8a5d7d5d5f5d5f8a5d7d5d5f5f
```

### **Recommandation 2 : RADIUS/TLS (chiffrement du trafic)**

Configure RADIUS sur port **2083 (TLS)** avec certificats SSL en production.

### **Recommandation 3 : Restriction IP sur firewall**

```bash
# Switch n'accepte RADIUS que du serveur 172.27.50.1
access-list 10 permit 172.27.50.1
aaa group server radius GROUPE-RADIUS-AG08
    access-list 10
end
```

---

## **12. Checklist de Déploiement**

```
✅ INSTALLATION
  □ FreeRADIUS installé
  □ Certificats générés (/etc/raddb/certs/)
  □ Clients RADIUS déclarés (FortiGate + Switch)
  □ Utilisateurs RADIUS créés (admin/operator/support)
  □ Service radiusd actif (sudo systemctl status radiusd)
  □ Firewall ouvert (1812/1813 UDP)

✅ CONFIGURATION SWITCH
  □ Radius server déclaré (RADIUS-AG08)
  □ AAA new-model activé
  □ Groupe RADIUS créé (GROUPE-RADIUS-AG08)
  □ Authentication, Authorization, Accounting configurés
  □ Lignes VTY/Console adaptées

✅ TESTS
  □ radtest local : Access-Accept reçu
  □ SSH admin@172.27.50.70 : OK (priv 15)
  □ SSH operator@172.27.50.70 : OK (priv 7)
  □ SSH support@172.27.50.70 : OK (priv 1)
  □ Compte fallback local (admini) accessible
  □ Logs RADIUS affichent connexions

✅ SÉCURITÉ
  □ Secret RADIUS identique partout
  □ Mots de passe forts
  □ Firewall configuré
  □ Backup local active
  □ Logs traceront tous accès
```

---

## **13. Commandes Utiles Récapitulatif**

```bash
# SERVEUR RADIUS
sudo systemctl restart radiusd
sudo systemctl status radiusd
sudo tail -f /var/log/radius/radius.log
radtest admin AdminPassword123 localhost 1812 testing123

# SWITCH CISCO (exec mode)
show radius
show running-config | include aaa
show running-config | include radius server
show accounting commands
```

---

**🎉 FreeRADIUS + AAA Cisco configurés avec succès !**  
**Authentification centralisée = sécurité ++, gestion simplifiée !**
