# 📋 PROCÉDURE COMPLÈTE D'IMPLÉMENTATION - Étape par étape

## 🎯 OBJECTIF FINAL

À la fin de ce guide, vous aurez :
- ✅ **3 contrôleurs de domaine** répliqués (Bruxelle, Namur, Mons)
- ✅ **200+ utilisateurs** importés avec structure de groupes
- ✅ **Serveur de fichiers** avec partages sécurisés et quotas
- ✅ **DHCP** pour 6 VLANs (172.28.10-50 + 172.28.99)
- ✅ **Stratégies de groupe** appliquées
- ✅ **Serveur Web HTTPS** accessible

---

## 📋 PRÉPARATION (Jour 0 - 1h)

### Étape 0.1 : Préparer les fichiers

```powershell
# Sur votre PC de travail :
# 1. Téléchargez tous les scripts PowerShell
#    - Scripts_01_Config_Reseau.ps1
#    - Scripts_02_Promotion_DC.ps1
#    - Script_03_Import_Utilisateurs.ps1
#    - Script_04-07_Serveur_Fichiers.ps1
#    - Script_08-09_GPO_WebServer.ps1

# 2. Téléchargez le CSV :
#    - Employes-Liste6_ADAPTEE.csv

# 3. Placez-les sur une clé USB ou un partage réseau
```

### Étape 0.2 : Vérifier l'infrastructure

```powershell
# Depuis votre PC, vérifiez la connectivité :

# Ping des serveurs (sur leurs IPs actuelles)
ping <IP-Bruxelle-temp>
ping <IP-Namur-temp>
ping <IP-Mons-temp>

# Vérifiez le routage :
ping 172.28.1.1   # Bruxelle
ping 172.25.0.1   # Namur (doit réussir via routeur/firewall)
ping 172.28.2.1   # Mons
```

### Étape 0.3 : Préparer les dossiers sur Bruxelle

```powershell
# Connectez-vous EN LOCAL sur le serveur BRUXELLE
# (Écran, clavier, souris)

# Ouvrir PowerShell ISE en Administrator :
Start-Process powershell_ise -Verb RunAs

# Créer le dossier pour le CSV :
mkdir C:\Install
```

---

## 🔧 PHASE 1 : CONFIGURATION RÉSEAU (Jour 1 - 30 min par serveur)

### Étape 1.1 : Script 01 sur BRUXELLE

**Sur le serveur Bruxelle :**

```powershell
# 1. Ouvrir PowerShell en Administrator
# 2. Exécuter le script 01 pour BRUXELLE
cd C:\Scripts
.\Scripts_01_Config_Reseau.ps1

# ⚠️ Choisir la section correspondant à BRUXELLE dans le script

# Résultat attendu :
# - IP configurée en 172.28.1.1
# - Serveur renommé en DC-BRUXELLE
# - Redémarrage automatique
```

**Après redémarrage :**
```powershell
# Vérifier :
ipconfig
# Doit afficher : 172.28.1.1

whoami
# Doit afficher : BRUXELLE\Administrateur (avant la promotion)
```

### Étape 1.2 : Script 01 sur NAMUR

**Sur le serveur Namur :**

```powershell
# ⚠️ IMPORTANT : NAMUR est sur un réseau DIFFÉRENT !

# 1. Exécuter le script 01 pour NAMUR
.\Scripts_01_Config_Reseau.ps1

# Résultat attendu :
# - IP configurée en 172.25.0.1 (réseau 172.25.x.x)
# - Serveur renommé en DC-NAMUR
# - DNS pointant vers 172.28.1.1 (Bruxelle)
# - Redémarrage automatique
```

**Après redémarrage :**
```powershell
# Tester connectivité vers Bruxelle :
ping 172.28.1.1
# ⚠️ Doit fonctionner ! Sinon vérifier routage firewall
```

### Étape 1.3 : Script 01 sur MONS

**Sur le serveur Mons :**

```powershell
# 1. Exécuter le script 01 pour MONS
.\Scripts_01_Config_Reseau.ps1

# Résultat attendu :
# - IP configurée en 172.28.2.1
# - Serveur renommé en DC-MONS-RO
# - DNS pointant vers 172.25.0.1 (Namur pour failover)
# - Redémarrage automatique
```

**Après redémarrage :**
```powershell
# Tester connectivité :
ping 172.28.1.1   # Bruxelle
ping 172.25.0.1   # Namur
```

---

## 🌳 PHASE 2 : PROMOTION DES DC (Jour 2 - 45 min)

### Étape 2.1 : Promotion DC Root sur BRUXELLE

**Sur le serveur Bruxelle :**

```powershell
# Attendre complètement après redémarrage (5 min)

# 1. Ouvrir PowerShell ISE en Administrator
# 2. Exécuter le script 02A
.\Scripts_02_Promotion_DC.ps1

# Résultat attendu :
# - Rôles AD DS, DNS, DHCP installés
# - DHCP configuré pour 6 VLANs
# - Forêt Belgique.lan créée
# - Redémarrage automatique (~10 min)
```

**Après redémarrage :**
```powershell
# Vérifier la promotion :
whoami
# Doit afficher : BELGIQUE\Administrateur

# Tester Active Directory :
Get-ADForest
# Doit afficher Belgique.lan

# Tester DNS :
Resolve-DnsName belgique.lan
# Doit résoudre

# Vérifier DHCP :
Get-DhcpServerv4Scope
# Doit afficher 6 scopes (VLAN10-50, VoIP99)
```

**🎉 Bruxelle est maintenant DC Master !**

### Étape 2.2 : Promotion Replica sur NAMUR

**Sur le serveur Namur :**

```powershell
# Attendre complètement après redémarrage (5 min)

# ⚠️ AVANT de lancer le script :
# Vérifier que Bruxelle est complètement prête
ping 172.28.1.1
nslookup belgique.lan
# Les deux doivent fonctionner

# 1. Ouvrir PowerShell ISE en Administrator
# 2. Exécuter le script 02B
.\Scripts_02_Promotion_DC.ps1

# Lors de l'exécution :
# - Le script demandera Belgique\Administrateur
# - Entrez le password défini à Bruxelle : P@ssword2025!
# - Le serveur se promote en Replica
# - Redémarrage automatique (~15 min)
```

**Après redémarrage :**
```powershell
# Vérifier :
whoami
# BELGIQUE\Administrateur

# Vérifier la synchronisation :
Get-ADUser -Filter * | Measure-Object
# Doit afficher > 0 utilisateurs (hérités de Bruxelle)

# Vérifier les DC :
Get-ADDomainController
# Doit afficher BRUXELLE et NAMUR
```

**🎉 Namur est maintenant DC Replica !**

### Étape 2.3 : Promotion RODC sur MONS

**Sur le serveur Mons :**

```powershell
# Attendre complètement après redémarrage (5 min)

# ⚠️ AVANT de lancer le script :
ping 172.25.0.1
nslookup belgique.lan
# Les deux doivent fonctionner

# 1. Ouvrir PowerShell ISE en Administrator
# 2. Exécuter le script 02C
.\Scripts_02_Promotion_DC.ps1

# Lors de l'exécution :
# - Le script demandera Belgique\Administrateur
# - Entrez le password défini à Bruxelle : P@ssword2025!
# - Le serveur se promote en RODC (lecture seule)
# - Redémarrage automatique (~15 min)
```

**Après redémarrage :**
```powershell
# Vérifier :
whoami
# BELGIQUE\Administrateur

# Vérifier les 3 DC :
Get-ADDomainController
# Affiche : BRUXELLE, NAMUR, DC-MONS-RO
```

**🎉 Infrastructure Active Directory complète !**

---

## 👥 PHASE 3 : IMPORT UTILISATEURS (Jour 3 - 20 min)

### Étape 3.1 : Préparer le CSV

**Sur Bruxelle :**

```powershell
# 1. Copier le fichier CSV :
Copy-Item "Employes-Liste6_ADAPTEE.csv" "C:\Install\Employes-Liste6.csv"

# 2. Vérifier :
Test-Path "C:\Install\Employes-Liste6.csv"
# Doit afficher : True
```

### Étape 3.2 : Exécuter le script d'import

**Sur Bruxelle :**

```powershell
# 1. Ouvrir PowerShell ISE en Administrator
# 2. Exécuter le script 03
.\Script_03_Import_Utilisateurs.ps1

# ⏳ Cela prend 5-10 minutes
# Le script crée :
#   - ~200 utilisateurs
#   - ~20 OUs (Départements/Sous-départements)
#   - ~40 groupes (GG_* et GL_*)
```

**Après exécution :**
```powershell
# Vérifier les utilisateurs :
Get-ADUser -Filter * | Measure-Object
# Doit afficher > 200

# Vérifier les OUs :
Get-ADOrganizationalUnit -Filter * | Measure-Object

# Vérifier un utilisateur spécifique :
Get-ADUser "r.aimant"
# Doit afficher l'utilisateur Rayan Aimant
```

**🎉 Annuaire peuplé !**

---

## 📁 PHASE 4 : SERVEUR DE FICHIERS (Jour 4 - 30 min)

### Étape 4.1 : Configuration complète

**Sur Bruxelle :**

```powershell
# 1. Ouvrir PowerShell ISE en Administrator
# 2. Exécuter le script 04-07
.\Script_04-07_Serveur_Fichiers.ps1

# ⏳ Cela prend 15-20 minutes
# Le script configure :
#   - Rôle FS Resource Manager
#   - Arborescence des dossiers
#   - Partages SMB
#   - Permissions NTFS
#   - Quotas (500 Mo / 100 Mo)
#   - Filtrage fichiers
```

**Après exécution :**
```powershell
# Vérifier l'arborescence :
dir C:\DossiersPartages

# Vérifier les partages :
Get-SmbShare

# Vérifier les quotas :
Get-FsrmQuota

# Tester l'accès (depuis un client sur le réseau) :
net use x: \\DC-BRUXELLE\DossiersPartages
# Doit afficher : Commande effectuée avec succès
```

**🎉 Serveur de fichiers opérationnel !**

---

## 🎯 PHASE 5 : GPO ET SERVEUR WEB (Jour 5 - 30 min)

### Étape 5.1 : Configuration des GPO

**Sur Bruxelle :**

```powershell
# 1. Ouvrir PowerShell ISE en Administrator
# 2. Exécuter le script 08 (première partie)
.\Script_08-09_GPO_WebServer.ps1

# ⏳ Cela prend 10-15 minutes
# Le script configure :
#   - Corbeille AD (180 jours)
#   - Script de logon (montage Y: et Z:)
#   - GPO restrictive (sauf Admin/IT)
#   - Liaison aux OUs
```

**Après exécution :**
```powershell
# Vérifier les GPO :
Get-GPO -All

# Vérifier les liaisons :
Get-GPLink -Target "DC=Belgique,DC=lan"
```

### Étape 5.2 : Configuration du serveur web

**Sur Bruxelle (suite du même script 08-09) :**

```powershell
# Après la partie GPO, le script installe IIS

# ⏳ 5-10 minutes
# Le script configure :
#   - Installation IIS
#   - Site web index.html
#   - Certificat SSL auto-signé
#   - Binding HTTPS:443
```

**Après exécution :**
```powershell
# Vérifier IIS :
Get-WebBinding

# Tester depuis un client (sur le réseau) :
# Ouvrir navigateur :
# https://www.Belgique.lan
# (Accepter l'avertissement certificat auto-signé)
```

**🎉 Infrastructure complète opérationnelle !**

---

## ✅ TESTS DE VÉRIFICATION

### Test 1 : Réplication AD

```powershell
# Sur BRUXELLE :
Get-ADDomainController

# Résultat attendu :
# - DC-BRUXELLE (Master)
# - DC-NAMUR (Replica)
# - DC-MONS-RO (RODC)
```

### Test 2 : DHCP

```powershell
# Sur BRUXELLE :
Get-DhcpServerv4Scope

# Résultat attendu :
# 6 scopes (VLAN10, VLAN20, VLAN30, VLAN40, VLAN50, VLAN99)
```

### Test 3 : Utilisateurs

```powershell
# Sur n'importe quel DC :
Get-ADUser -Filter {Department -eq "Informatique"} | Measure-Object

# Résultat attendu :
# > 20 utilisateurs
```

### Test 4 : Partages

```powershell
# Depuis un client Windows 10 sur le réseau :
net use x: \\DC-BRUXELLE\DossiersPartages

# Résultat attendu :
# Commande effectuée avec succès

# Vérifier l'accès :
dir x:\
# Doit afficher : Commun, Departements
```

### Test 5 : RODC (Mons)

```powershell
# Sur DC-MONS-RO :
Get-ADDomainController -Identity DC-MONS-RO

# Vérifier que IsReadOnly = True
```

### Test 6 : GPO

```powershell
# Depuis un client joint au domaine :
gpresult /H rapport.html

# Ouvrir rapport.html dans navigateur
# Vérifier que GPO_Employes_Standard est appliquée
```

---

## 🐛 TROUBLESHOOTING COURANT

### ❌ Erreur : "Impossible de se connecter à DC"

**Symptôme :** Script 02B ou 02C échoue

**Solution :**
```powershell
# 1. Vérifier routage
ping 172.25.0.1
ping 172.28.1.1

# 2. Vérifier DNS
nslookup belgique.lan

# 3. Si nslookup échoue :
# → DNS n'est pas repliqué
# → Attendre 5 min après redémarrage de Bruxelle
```

### ❌ Erreur : "Impossible de lire le CSV"

**Solution :**
```powershell
# Vérifier le chemin :
Test-Path "C:\Install\Employes-Liste6.csv"

# Si False, copier le fichier :
Copy-Item "Employes-Liste6_ADAPTEE.csv" "C:\Install\Employes-Liste6.csv"
```

### ❌ Utilisateurs ne se connectent pas au domaine

**Solution :**
```powershell
# 1. Vérifier que l'utilisateur existe :
Get-ADUser "r.aimant"

# 2. Vérifier que DHCP est actif :
Get-DhcpServerv4Scope

# 3. Vérifier que le client peut ping le DC :
# (Depuis le client)
ping DC-BRUXELLE.belgique.lan
```

### ❌ Partage SMB pas accessible

**Solution :**
```powershell
# Vérifier le partage :
Get-SmbShare -Name DossiersPartages

# Vérifier les permissions :
icacls C:\DossiersPartages

# Tester depuis client :
net view \\DC-BRUXELLE
# Doit afficher les partages
```

---

## 📞 SUPPORT & DOCUMENTATION

Pour plus d'informations sur chaque composant, consultez :

- **Active Directory** : `Get-Help Get-ADUser -Full`
- **DHCP** : `Get-Help Get-DhcpServerv4Scope -Full`
- **GPO** : `Get-Help Get-GPO -Full`
- **File Server** : `Get-Help Get-FsrmQuota -Full`

---

## ⏱️ RÉSUMÉ CHRONOLOGIQUE

```
JOUR 1 : Configuration réseau (1h)
  - Script 01A (Bruxelle) : 15 min
  - Script 01B (Namur) : 15 min
  - Script 01C (Mons) : 15 min

JOUR 2 : Promotion DC (1h 15 min)
  - Script 02A (Bruxelle DC Root) : 25 min
  - Script 02B (Namur Replica) : 25 min
  - Script 02C (Mons RODC) : 25 min

JOUR 3 : Import utilisateurs (20 min)
  - Script 03 : 20 min

JOUR 4 : Serveur fichiers (30 min)
  - Script 04-07 : 30 min

JOUR 5 : GPO et Web (30 min)
  - Script 08-09 : 30 min

TOTAL : ~3h 35 min d'exécution réelle
```

---

**✅ Infrastructure complète et opérationnelle !**