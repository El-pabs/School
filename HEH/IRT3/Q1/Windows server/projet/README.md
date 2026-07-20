# 🔐 Infrastructure Belgique.lan - Documentation Complète

> **Suite de scripts PowerShell professionnelle pour déployer et gérer une infrastructure Active Directory multi-sites d'entreprise**

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture réseau](#architecture-réseau)
3. [Scripts disponibles](#scripts-disponibles)
4. [Guide de déploiement](#guide-de-déploiement)
5. [Configuration détaillée](#configuration-détaillée)
6. [Maintenance et dépannage](#maintenance-et-dépannage)
7. [Sécurité](#sécurité)

---

## 🎯 Vue d'ensemble

Cette suite complète automatise le déploiement d'une **infrastructure Active Directory multi-sites** pour l'entreprise Belgique avec :

| Composant | Détail |
|-----------|--------|
| **Forêt AD** | `Belgique.lan` |
| **DCs** | 3 serveurs (Bruxelles, Namur, Mons) |
| **VLANs** | 14 réseaux par site (Agence 9 & Agence 6) |
| **Utilisateurs** | Import depuis CSV avec génération de mots de passe |
| **Backups** | Sauvegarde locale + NAS avec rétention |
| **Services** | DHCP, DNS, Backup, SMTP, Web HTTPS |

---

## 🏗️ Architecture Réseau

### Sites et Adressage

**Agence 9 (Bruxelles - Master)**
```
VLAN 10  → Informatique    (172.28.10.0/24)  - DC: 172.28.60.21
VLAN 15  → Commerciaux     (172.28.15.0/24)
VLAN 20  → Technique       (172.28.20.0/24)
VLAN 25  → Finances        (172.28.25.0/24)
VLAN 30  → Marketing       (172.28.30.0/24)
VLAN 35  → R&D             (172.28.35.0/24)
VLAN 40  → RH              (172.28.40.0/24)
VLAN 45  → Direction       (172.28.45.0/24)
VLAN 50  → Gestion         (172.28.50.0/24)
VLAN 55  → Transit         (172.28.55.0/24)
VLAN 60  → Serveurs        (172.28.60.0/24)
VLAN 65  → VoIP            (172.28.65.0/24)
VLAN 100 → Natif           (172.28.100.0/24)
VLAN 199 → Poubelle        (172.28.199.0/24)
```

**Agence 6 (Namur - Replica)**
```
Même structure avec plage 172.25.x.0/24
DC: 172.25.60.21
```

**Mons (Read-Only DC)**
```
172.27.60.21 - Réplication depuis Namur
```

---

## 📦 Scripts Disponibles

### 1️⃣ **01-Config-Reseau-SIMPLE.ps1** - Configuration Réseau
Configure l'adresse IP, le nom du serveur et les DNS.

**Utilisation :**
```powershell
# Éditer le script et décommenter la section du serveur
# Bruxelles (DC-BRUXELLES) - IP: 172.28.60.21
# Namur (DC-NAMUR) - IP: 172.25.60.21
# Mons (DC-MONS-RO) - IP: 172.27.60.21
.\01-Config-Reseau-SIMPLE.ps1
```

**Étapes :**
- ✅ Configure IPv4 + Gateway + DNS
- ✅ Renomme le serveur
- ✅ Redémarrage automatique
- ✅ Teste la connectivité réseau

---

### 2️⃣ **prep_dc_bruxelles.ps1** - Promotion DC Root
Promeut le serveur en contrôleur de domaine racine.

```powershell
.\prep_dc_bruxelles.ps1
```

**Fonctionnalités :**
- 🌳 Création de la forêt `Belgique.lan`
- 🔧 Installation des rôles AD-DS
- 📊 Configuration des zones DNS
- ⚙️ Initialisation de la réplication

---

### 3️⃣ **Mise-en-place-replication-dc-root.ps1** - Réplication Multi-site
Promeut les DCs secondaires et configure la réplication.

```powershell
# Sur Namur
.\Mise-en-place-replication-dc-root.ps1

# Sur Mons (RODC)
# Version RODC à adapter
```

**Configuration :**
- ↔️ Réplication DC Bruxelles → Namur
- ↔️ Réplication Namur → Mons (Read-Only)
- 🔐 Établit les relations de confiance

---

### 4️⃣ **Script_03_AD.ps1** - Import Utilisateurs
Importe les utilisateurs depuis CSV et crée la structure OUs.

```powershell
.\Script_03_AD.ps1
```

**Prérequis :** `Employes-Liste6_ADAPTEE.csv` dans Documents

**Processus (7 étapes) :**

| # | Étape | Détail |
|---|-------|--------|
| 1️⃣ | Lecture CSV | Import du fichier d'employés |
| 2️⃣ | Création OUs | Hiérarchie par département |
| 3️⃣ | Génération MdP | 20 caractères sécurisés aléatoires |
| 4️⃣ | Création users | Account AD + mailbox |
| 5️⃣ | Délégations | Droits administratifs par OU |
| 6️⃣ | Horaires logon | Restrictions horaires |
| 7️⃣ | Export logs | CSV des utilisateurs/mots de passe |

**Normalisations appliquées :**
- ✅ Suppression des accents (é→e, à→a)
- ✅ Format SamAccountName: `prenom.nom`
- ✅ UPN: `prenom.nom@belgique.lan`
- ✅ Gestion des doublons avec suffixes

---

### 5️⃣ **Script_25_DHCP.ps1** - Configuration DHCP
Configure les scopes DHCP pour tous les VLANs.

```powershell
# Phase 1 (avant redémarrage)
.\Script_25_DHCP.ps1

# Phase 2 (après redémarrage du DC)
# Exécuter la deuxième partie du script
```

**Scopes créés :** 28 scopes DHCP
- 14 pour Agence 9
- 14 pour Agence 6

**Options DHCP :**
- Gateway (option 3)
- DNS (option 6)
- Domain Name (option 15)
- Durée de bail: 8 heures

---

### 6️⃣ **Script_08_Backup_LOCAL_NAS.ps1** - Sauvegarde
Sauvegarde locale + NAS avec rétention automatique.

```powershell
.\Script_08_Backup_LOCAL_NAS.ps1
```

**Répertoires sauvegardés :**
- `C:\Windows\SYSVOL` - Données partagées AD
- `C:\Windows\NTDS` - Base de données AD
- `C:\inetpub` - Site web IIS
- `C:\Windows\System32\dhcp` - Configuration DHCP
- `C:\Share` - Partages généraux

**Destinations :**
- 📁 Local: `C:\Backups`
- 🖥️ NAS: `\\192.168.2.198\Agence9`

**Fonctionnalités :**
- 🔄 Synchronisation bidirectionnelle (Robocopy)
- 📊 Logs détaillés par backup
- 🗑️ Nettoyage automatique (7 jours)
- 📈 Rapport CSV (`BackupSummary_YYYY-MM-DD.csv`)

---

### 7️⃣ **Script_085_Schedule_Tasks_backup.ps1** - Planification
Crée des tâches planifiées Windows pour les backups.

```powershell
.\Script_085_Schedule_Tasks_backup.ps1
```

**Tâches planifiées :**
- 🕐 Backup quotidien 23:00
- 🕐 Backup incrémenta 12:00
- 🧹 Nettoyage hebdo dimanche 03:00

---

### 8️⃣ **Script_08-09_GPO_WebServer.ps1** - Serveur Web HTTPS
Configure un serveur web IIS avec certificat SSL.

```powershell
.\Script_08-09_GPO_WebServer.ps1
```

**Installation :**
- 🌐 IIS + Management Tools
- 🔒 Certificat SSL auto-signé
- 📄 Page d'accueil HTTPS

**Accès :**
```
https://www.Belgique.lan  (Certificat auto-signé = ⚠️ avertissement)
```

---

### 9️⃣ **Setup-SMTP-Relay-IIS.ps1** - Relai SMTP
Configure un relai SMTP sur IIS.

```powershell
.\Setup-SMTP-Relay-IIS.ps1
```

**Configuration :**
- 📧 Service SMTP Windows
- 🔐 Authentification intégrée
- 📤 Relai d'e-mails sortants

---

### 🔟 **Lister_rh.ps1** - Export RH
Exporte les utilisateurs du département RH.

```powershell
.\Lister_rh.ps1
```

**Sortie :** CSV avec:
- SamAccountName
- DisplayName
- Email
- Numéro de téléphone

---

### 1️⃣1️⃣ **manageurs_droit.ps1** - Délégations Administratives
Configure les droits administratifs par OU.

```powershell
.\manageurs_droit.ps1
```

**Mapping :**
| Département | Manager AD | Droits |
|-------------|-----------|--------|
| Commerciaux | yan.kowal | Gestion OU + Users |
| Technique | axel.irakoze | Gestion Ordinateurs |
| Informatique | adrien.ilic | Admin OU complète |
| RH | romain.marcel | Gestion Users |
| Direction | pol.kuntonda-luezi | Lecture seule |
| R&D | antoine.brard | Gestion OU |
| Marketing | maxime.gudin | Lecture users |
| Finances | benjamin.tollet | Gestion Finance |

---

### 1️⃣2️⃣ **FixGroupsManagers.ps1** - Correction Groupes
Corrige les appartenance aux groupes de managers.

```powershell
.\FixGroupsManagers.ps1
```

---

### 1️⃣3️⃣ **reset_ad.ps1** - Nettoyage Complet ⚠️
**DANGER** - Supprime tous les utilisateurs et OUs.

```powershell
.\reset_ad.ps1
# Confirmation: "OUI"
```

**Actions :**
- 🗑️ Supprime tous les users (sauf system)
- 🗑️ Deverrouille les OUs
- 🗑️ Supprime toute la hiérarchie

**Utilisation :** Reset complet avant redéploiement

---

## 🚀 Guide de Déploiement

### Phase 1: Préparation (15 min)

```powershell
# Sur DC-BRUXELLES (serveur vierge Windows Server 2019+)
PS> .\01-Config-Reseau-SIMPLE.ps1
# ↳ Redémarrage automatique
```

### Phase 2: Promotion DC Root (30 min)

```powershell
# Après redémarrage
PS> .\prep_dc_bruxelles.ps1
# ✅ Forêt Belgique.lan créée
# ✅ DNS configuré
```

### Phase 3: Structure Active Directory (20 min)

```powershell
# Dossier Documents doit contenir:
# - Employes-Liste6_ADAPTEE.csv

PS> .\Script_03_AD.ps1
# ✅ OUs créées (14 depts)
# ✅ Utilisateurs importés
# ✅ Mots de passe générés
# ✅ Logs: C:\Backups\Logs\*
```

### Phase 4: Configuration DHCP (20 min)

```powershell
PS> .\Script_25_DHCP.ps1
# ↳ Redémarrage du DHCP

# Après redémarrage complet du DC
PS> .\Script_25_DHCP.ps1  # Partie 2
# ✅ Scopes activés
# ✅ Options DNS/Gateway
```

### Phase 5: Sauvegarde (15 min)

```powershell
PS> .\Script_08_Backup_LOCAL_NAS.ps1
# ✅ Backup local créé
# ✅ Backup NAS créé
# ✅ Logs: C:\Backups\Logs\

PS> .\Script_085_Schedule_Tasks_backup.ps1
# ✅ Tâches planifiées créées
```

### Phase 6: Services Additionnels (10 min)

```powershell
PS> .\Script_08-09_GPO_WebServer.ps1    # Web HTTPS
PS> .\Setup-SMTP-Relay-IIS.ps1          # Email
PS> .\manageurs_droit.ps1               # Délégations
```

### Phase 7: DCs Secondaires (30 min par site)

**Sur DC-NAMUR :**
```powershell
PS> .\01-Config-Reseau-SIMPLE.ps1       # Adapter IP
PS> .\Mise-en-place-replication-dc-root.ps1
# ✅ Réplication Bruxelles → Namur
```

**Sur DC-MONS-RO :**
```powershell
PS> .\01-Config-Reseau-SIMPLE.ps1       # Adapter IP
# Adapter script replication pour RODC
```

---

## ⚙️ Configuration Détaillée

### Format CSV Employés

`Employes-Liste6_ADAPTEE.csv` (délimiteur `;`)

```csv
Prenom;Nom;Departement;Bureau;Description;Fonction
Jean;Dupont;Informatique/Systèmes;Bruxelles;Administrateur;Technicien Systèmes
Marie;Martin;Commerciaux/Sédentaires;Namur;Commerciale;Commerciale terrain
...
```

**Champs :**
- `Prenom` - Prénom (avec accents OK)
- `Nom` - Nom de famille
- `Departement` - Format: `Sous-dept/Categorie` ou `Categorie`
- `Bureau` - Localisation
- `Description` - Libellé libre
- `Fonction` - Poste de travail

**Structure OUs créée :**
```
DC=Belgique,DC=lan
├── OU=Informatique
│   ├── OU=Systèmes
│   ├── OU=HotLine
│   └── OU=Développement
├── OU=Commerciaux
│   ├── OU=Sédentaires
│   └── OU=Technico
├── OU=Technique
│   ├── OU=Achat
│   └── OU=Techniciens
├── OU=Finances
│   ├── OU=Comptabilité
│   └── OU=Investissements
├── OU=RH
│   ├── OU=Gestion du personnel
│   └── OU=Recrutement
├── OU=R&D
│   ├── OU=Recherche
│   └── OU=Testing
├── OU=Marketing
│   ├── OU=Site1
│   ├── OU=Site2
│   ├── OU=Site3
│   └── OU=Site4
├── OU=Direction
└── OU=Ordinateurs
```

### Génération Mots de Passe

**Algorithme sécurisé :**
- 🔐 20 caractères aléatoires
- ✅ Lettres majuscules/minuscules
- ✅ Chiffres (2-9)
- ✅ Caractères spéciaux (!@#$%^&*)
- ✅ Préfixe garanti: `A1!@`

**Exemple :** `A1!@Kx7mQ$pN2vB@9sRt`

**Log :** `C:\Backups\Logs\Backup_YYYY-MM-DD_HHMMSS.log`

### Chemin Accès NAS

**Connexion :**
```
Serveur: 192.168.2.198
Partage: \Agence9
Username: Agence9
Password: Test1234*
```

⚠️ **SÉCURITÉ :** Modifier le mot de passe après déploiement !

---

## 🔧 Maintenance et Dépannage

### Vérifier la Santé AD

```powershell
# Réplication
Get-ADReplicationSiteLink | Select Name, ReplicationFrequency

# Partenaires réplication
Get-ADReplicationConnection | Select SourceServer, TargetServer, Status

# Locataires domaine
Get-ADForest Belgique.lan | Select Name, RootDomain

# Sites
Get-ADReplicationSite | Select Name, Description
```

### Renouveler Certificat SSL

```powershell
$Cert = New-SelfSignedCertificate `
    -DnsName "www.Belgique.lan","Belgique.lan" `
    -CertStoreLocation "cert:\LocalMachine\My" `
    -FriendlyName "Belgique Web 2025" `
    -NotAfter (Get-Date).AddYears(2)

Get-WebBinding -Protocol https | ForEach-Object {
    $_.AddSslCertificate($Cert.Thumbprint, "My")
}
```

### Debugger Problèmes DHCP

```powershell
# Voir les scopes
Get-DhcpServerv4Scope | Select Name, StartRange, EndRange, State

# Vérifier les réservations
Get-DhcpServerv4Reservation

# Logs DHCP
Get-WinEvent -LogName "DhcpAdminEvents" -MaxEvents 50

# Tester pool
Get-DhcpServerv4DhcpStatistics
```

### Restaurer Utilisateur Supprimé

```powershell
# Récupérer les objets supprimés
Get-ADObject -Filter {isDeleted -eq $true} -IncludeDeletedObjects

# Restaurer
Restore-ADObject -Identity "<ObjectGUID>" -Confirm:$false
```

---

## 🔐 Sécurité

### Meilleures Pratiques

#### 1. Active Directory
- ✅ Utiliser mots de passe complexes (20+ chars)
- ✅ Activer la Corbeille AD (déjà fait)
- ✅ Implémenter MFA pour admins
- ✅ Auditer les modifications
- ✅ Protéger les OUs contre suppression accidentelle

#### 2. Réseau
- ✅ Isoler les VLANs par département
- ✅ VLAN 199 pour équipements non triés
- ✅ Firewall entre VLANs sensibles
- ✅ VLAN 60 pour serveurs (DNS, DHCP)
- ✅ VLAN 65 réservé VoIP

#### 3. Backups
- ✅ Local + NAS (redondance)
- ✅ Rétention 7 jours
- ✅ Vérifier backups régulièrement
- ✅ Tester restauration mensuelle
- ✅ Chiffrer accès NAS

#### 4. Services
- ✅ SMTP: Authentification obligatoire
- ✅ Web: HTTPS auto-signé → signer correctement
- ✅ DHCP: Autoriser dans AD uniquement
- ✅ DNS: Zones sécurisées (DNSSEC)

---

## 📊 Logs et Diagnostics

### Emplacements Logs

```
C:\Backups\
├── Logs/
│   ├── Backup_YYYY-MM-DD_HHMMSS.log      (Détail backup)
│   ├── BackupSummary_YYYY-MM-DD.csv      (Résumé CSV)
│   ├── robocopy_*.log                     (Robocopy détail)
│   └── PasswordLog_*.log                  (Users créés)
```

### Analyser les Logs

```powershell
# Derniers backups
Get-Content "C:\Backups\Logs\BackupSummary_$(Get-Date -Format 'yyyy-MM-dd').csv"

# Derniers logs d'erreurs
Get-EventLog -LogName Application -Newest 20 | Where-Object EntryType -eq "Error"

# Logs AD
Get-WinEvent -LogName "Directory Service" -MaxEvents 50
```

---

## 📞 Support et Ressources

### Documentation Externe
- [Microsoft AD DS Documentation](https://docs.microsoft.com/windows-server/identity/)
- [PowerShell AD Module](https://docs.microsoft.com/powershell/module/activedirectory/)
- [DHCP Best Practices](https://docs.microsoft.com/windows-server/networking/technologies/dhcp/dhcp-top/)

### Vérifications Pré-Déploiement

- ✅ Windows Server 2019+ avec 20 GB disque libre
- ✅ Accès réseau stables entre sites
- ✅ Serveurs testés isolément
- ✅ CSV employés formaté correctement
- ✅ NAS accessible (ping 192.168.2.198)
- ✅ Sauvegarde préalable données existantes

---

## 📝 Version et Historique

| Version | Date | Changements |
|---------|------|-------------|
| 1.0 | 2025-12-08 | Version initiale |
| 1.1 | - | Améliorations planifiées |

---

## 📄 Licence et Utilisation

Suite de scripts **propriétaire** - Belgique.lan
Utilisation autorisée uniquement pour l'infrastructure Belgique.

⚠️ **IMPORTANT:** Tester tous les scripts dans un environnement de test avant production.

---

**Créé pour une infrastructure enterprise robuste, sécurisée et scalable.**

*Last updated: 2025-12-08*