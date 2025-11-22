Voici **un document explicatif + un script complet "clé en main"** pour installer/configurer un serveur FreeRADIUS sous Linux **adapté à une infra FortiGate** (et Cisco/clients standards) avec tous les points de troubleshooting et de vérification utiles.

***

# 🛰️ **DOCUMENTATION : Mise en place FreeRADIUS pour FortiGate/Cisco**

***

## **1. Objectif**

- Centraliser l’authentification (admin/tech) sur un serveur FreeRADIUS
- Gérer les droits (admin/opérateur/support)  
- Permettre l’accès sécurisé sur FortiGate (et pour SSH/Telnet Cisco si besoin)

***

## **2. Topologie**

```
[Admin PC/SSH]---[LAN/VLAN 50]---[FortiGate AGG-TRUNK.50.1]---[Linux FreeRADIUS]
```
- Le serveur RADIUS (Linux) a une IP sur le même VLAN que l’interface du FortiGate/le switch.

***

## **3. Script complet d’installation/configuration FreeRADIUS**

```bash
#!/bin/bash

### ===== INFORMATIONS DE BASE ===== ###
RADIUS_SECRET="SuperSecretRadius2025!"
FG_IP="172.27.50.1"
USER_ADMIN="admin"
PWD_ADMIN="AdminPassword123"
USER_OPERATOR="operator"
PWD_OPERATOR="OperatorPass789"
USER_SUPPORT="support"
PWD_SUPPORT="SupportPass102"

cat << "EOF"
╔═════════════════════════════════════════════════════════════════╗
║         FreeRADIUS (FortiGate - Cisco / Agence 08)            ║
╚═════════════════════════════════════════════════════════════════╝
EOF

set -e

echo "
🛠️  Installation/Update des paquets nécessaires...
"
sudo dnf update -y
sudo dnf install -y freeradius freeradius-utils

echo "
📂 Configuration et génération des certificats pour EAP (si besoin)
"
cd /etc/raddb/certs/
sudo make clean > /dev/null 2>&1 || true
sudo ./bootstrap > /dev/null 2>&1 || true

echo "
⚙️  Configuration du client RADIUS (FortiGate & localhost)
"
sudo tee /etc/raddb/clients.conf > /dev/null <<EOF
client fortigate-agence08 {
    ipaddr = $FG_IP
    secret = $RADIUS_SECRET
    shortname = fortigate-agence08
}
client localhost {
    ipaddr = 127.0.0.1
    secret = testing123
    shortname = localhost
}
EOF

echo "
🔑 Configuration des utilisateurs et droits
"
sudo tee /etc/raddb/users > /dev/null <<EOF
$USER_ADMIN Cleartext-Password := "$PWD_ADMIN"
    Service-Type = NAS-Prompt-User,
    Cisco-AVPair = "shell:priv-lvl=15",
    Reply-Message = "Bienvenue Administrateur RADIUS"

$USER_OPERATOR Cleartext-Password := "$PWD_OPERATOR"
    Service-Type = NAS-Prompt-User,
    Cisco-AVPair = "shell:priv-lvl=7",
    Reply-Message = "Bienvenue Opérateur RADIUS"

$USER_SUPPORT Cleartext-Password := "$PWD_SUPPORT"
    Service-Type = NAS-Prompt-User,
    Cisco-AVPair = "shell:priv-lvl=1",
    Reply-Message = "Bienvenue Support RADIUS"

DEFAULT Cleartext-Password := "DefaultPassword999"
    Service-Type = NAS-Prompt-User,
    Cisco-AVPair = "shell:priv-lvl=0"
EOF

sudo chown -R radiusd:radiusd /etc/raddb/

echo "
🚦 Activation & démarrage du service FreeRADIUS
"
sudo systemctl enable radiusd
sudo systemctl restart radiusd

echo "
🐾 Test local du RADIUS (sur le serveur)
"
radtest $USER_ADMIN $PWD_ADMIN localhost 1812 testing123

echo "
✅ Serveur FreeRADIUS prêt !
Résumé :
→ Client FortiGate : $FG_IP / secret : $RADIUS_SECRET
→ Utilisateurs : admin/$PWD_ADMIN | operator/$PWD_OPERATOR | support/$PWD_SUPPORT
→ Service : actif ? sudo systemctl status radiusd
"
```

**Enregistre sous `radius_install.sh` et lance :**
```
chmod +x radius_install.sh; sudo ./radius_install.sh
```

***

## **4. Configuration FortiGate**

1. **Ajoute le serveur RADIUS dans le VDOM concerné**
   ```shell
   config user radius
       edit "RADIUS_LINUX"
           set server <IP_DU_SERVEUR_LINUX>
           set secret SuperSecretRadius2025!
           set source-ip 172.27.50.1
           set authentication pap
       next
   end
   ```

2. **Groupe d’utilisateurs pour l’admin RADIUS :**
   ```shell
   config user group
       edit "Admins-RADIUS"
           set member "RADIUS_LINUX"
       next
   end
   ```

3. **Mapping profil admin (Admin Profiles) :**
   - Va dans *System > Administrators > Create New*
   - *Type* : RADIUS
   - *Group* : Admins-RADIUS 
   - *Profile* : super_admin ou personnalisé

4. **Firewall Linux (ouvrir 1812/1813 UDP) :**
   ```bash
   sudo firewall-cmd --add-port=1812/udp --permanent
   sudo firewall-cmd --add-port=1813/udp --permanent
   sudo firewall-cmd --reload
   ```

***

## **5. Tests concrets**

- **En local Linux :**
  ```bash
  radtest admin AdminPassword123 localhost 1812 testing123
  ```

- **Depuis le FortiGate :**
  ```shell
  diagnose test authserver radius RADIUS_LINUX pap admin AdminPassword123
  ```

- **Se connecter à l’interface d’admin FortiGate avec admin/operator/support pour valider les droits**.

- **Tracer les accès :**
  ```bash
  sudo tail -f /var/log/radius/radius.log
  ```

***

## **6. Troubleshooting avancé / FAQ**

- **radtest local marche mais pas depuis FortiGate**
  - Firewall Linux (1812/1813 UDP ?)
  - RADIUS configuré sur la bonne IP côté Linux ET côté FortiGate ?
  - Adresse “set source-ip” sur FortiGate = l’IP déclarée dans clients.conf

- **Erreur "Access-Reject"**
  - Mauvais user/pass
  - Mauvais “secret” déclaré côté FortiGate ou côté FreeRADIUS

- **Plusieurs agences/sites** :
  - Déclare chaque IP source dans `/etc/raddb/clients.conf`
  - Chaque secret peut être distinct

- **Côté Cisco (bonus)**
  ```shell
  aaa new-model
  radius-server host <IP_RADIUS> key SuperSecretRadius2025!
  aaa authentication login default group radius local
  ```

***

**Ton FreeRADIUS est prêt, modulaire, et débogable !  
Besoin d’autre chose ? Demande le use-case précis (switch NAC, wifi, etc) !**