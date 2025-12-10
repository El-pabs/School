# 🚀 GUIDE COMPLET D'IMPLÉMENTATION - BELGIQUE.LAN

## 📋 TABLE DES MATIÈRES

1. [Vue d'ensemble](#vue-densemble)
2. [Infrastructure réseau](#infrastructure-réseau)
3. [Architecture Active Directory](#architecture-active-directory)
4. [Étapes d'exécution](#étapes-dexécution)
5. [Analyse détaillée des scripts](#analyse-détaillée-des-scripts)
6. [Troubleshooting](#troubleshooting)

---

## VUE D'ENSEMBLE

### Objectif global
Créer une infrastructure **Windows Server Active Directory** complète pour la société Belgique avec :
- **3 contrôleurs de domaine** (Bruxelle, Namur, Mons)
- **Annuaire LDAP** avec gestion des utilisateurs et groupes
- **Serveur de fichiers** avec partages sécurisés et quotas
- **Stratégies de groupe (GPO)** pour la gestion des postes clients
- **Serveur Web HTTPS** accessible de l'extérieur

### Domaine
- **Forêt** : Belgique.lan
- **Sites AD** : BRUXELLE (site principal), NAMUR (replica), MONS (RODC)

---

## INFRASTRUCTURE RÉSEAU

### 📍 Topologie physique
```
┌─────────────────────────────────────────┐
│         SERVEURS (Switch VLAN)          │
├─────────────────────────────────────────┤
│  DC-BRUXELLE (172.28.1.1)               │
│  DC-NAMUR (172.25.0.1)  ← Réseau distant│
│  DC-MONS-RO (172.28.2.1)                │
└─────────────────────────┬─────────────────┘
                          │
                      ┌───┴────────────┐
                   Switch             │
              (VLAN 1 = Native)        │
                      │                │
      ┌───────────────┼───────────────┐│
      │               │               ││
    VLAN 10        VLAN 20         VLAN 30...
   (Admin)         (R&D)         (Informatique)
   172.28.10.0     172.28.20.0    172.28.30.0
```

### 🌐 Adresses IP

| Composant | IP | Subnet | Role |
|-----------|-------|--------|------|
| **DC-BRUXELLE** | 172.28.1.1 | 172.28.0.0/16 | Maître |
| **DC-NAMUR** | 172.25.0.1 | 172.25.0.0/16 | Replica |
| **DC-MONS-RO** | 172.28.2.1 | 172.28.0.0/16 | RODC |
| **Clients VLAN 10** | 172.28.10.50-150 | 172.28.10.0/24 | Admin/RH |
| **Clients VLAN 20** | 172.28.20.50-150 | 172.28.20.0/24 | R&D |
| **Clients VLAN 30** | 172.28.30.50-150 | 172.28.30.0/24 | Informatique |
| **Clients VLAN 40** | 172.28.40.50-150 | 172.28.40.0/24 | Commercial |
| **Clients VLAN 50** | 172.28.50.50-150 | 172.28.50.0/24 | Technique |
| **Voix IP VLAN 99** | 172.28.99.50-150 | 172.28.99.0/24 | Téléphones |

### 📊 Routage requis

**Entre Bruxelle/Mons (même réseau) et Namur (réseau distinct) :**
```powershell
# Sur le Firewall/Routeur :
- 172.28.0.0/16 ↔ 172.25.0.0/16
- Tous les serveurs doivent pouvoir se ping mutuellement
```

**Vérification avant de commencer :**
```bash
ping 172.28.1.1   # DC-BRUXELLE
ping 172.25.0.1   # DC-NAMUR
ping 172.28.2.1   # DC-MONS-RO
```

---

## ARCHITECTURE ACTIVE DIRECTORY

### Structure des Unités d'Organisation (OU)

```
DC=Belgique,DC=lan
├── OU=Direction
├── OU=Ressources humaines
│   ├── OU=Gestion du personnel
│   └── OU=Recrutement
├── OU=R&D
│   ├── OU=Recherche
│   └── OU=Testing
├── OU=Finances
│   ├── OU=Comptabilité
│   └── OU=Investissements
├── OU=Informatique
│   ├── OU=HotLine
│   ├── OU=Développement
│   └── OU=Systèmes
├── OU=Technique
│   ├── OU=Achat
│   └── OU=Techniciens
├── OU=Marketting
│   ├── OU=Site1
│   ├── OU=Site2
│   ├── OU=Site3
│   └── OU=Site4
├── OU=Commerciaux
│   ├── OU=Sédentaires
│   └── OU=Technico
├── OU=Computers
│   ├── OU=VLAN10 (Admin)
│   ├── OU=VLAN20 (R&D)
│   ├── OU=VLAN30 (IT)
│   ├── OU=VLAN40 (Commercial)
│   └── OU=VLAN50 (Technique)
└── OU=Domain Controllers
```

### 👥 Modèle de groupes (AGDLP)

Pour chaque département/sous-département :

```
Account → Global Group (GG_*)  →  Domain Local Group (GL_*) → Resource (Dossier partagé)
          (Membres utilisateurs)    (Permissions NTFS)
```

**Exemple : Département RH**
```
Utilisateurs de Gestion → GG_Gestion → GL_Gestion_RW → \\Serveur\DossiersPartages\RH\Gestion
```

### 🔐 Groupes spéciaux

| Groupe | Rôle | Permission |
|--------|------|-----------|
| **GG_DIRECTION** | Administrateurs métier | FullControl tous dossiers |
| **GG_*Département*** | Utilisateurs du département | Selon OU |
| **GL_*_RW** | Accès Read/Write localisé | Permissions NTFS |
| **Domain Admins** | Administrateurs techniques | Tous droits système |

---

## ÉTAPES D'EXÉCUTION

### ⏱️ Chronologie globale

```
JOUR 1 : Configuration réseau et DC Root
├─ 08:00 - Préparation infrastructure
├─ 08:30 - Script 01 : Config IP Bruxelle + redémarrage (5 min)
├─ 08:45 - Script 02A : Promotion DC Root (10 min + redémarrage)
└─ 09:00 → BRUXELLE est maintenant DC Master ✅

JOUR 2 : Replica et RODC
├─ 09:00 - Script 01 : Config IP NAMUR + redémarrage
├─ 09:20 - Script 02B : Promotion Replica NAMUR (15 min)
├─ 09:45 - Script 01 : Config IP MONS + redémarrage
└─ 10:05 - Script 02C : Promotion RODC MONS (15 min)

JOUR 3 : Utilisateurs et groupes
├─ 14:00 - Script 03 : Import CSV (import-users.ps1) → 200+ utilisateurs + OUs ✅
└─ 14:30 - Vérifier AD avec ADUC

JOUR 4 : Serveur de fichiers
├─ 10:00 - Script 04 : Installation rôles FS + partages
├─ 10:20 - Script 05 : Configuration permissions NTFS
├─ 11:00 - Script 06 : Configuration quotas
└─ 12:00 - Script 07 : Filtrage fichiers

JOUR 5 : GPO et administration
├─ 09:00 - Script 08 : GPO restrictive (wallpaper, cmd bloqué, etc.)
├─ 10:00 - Script 08b : GPO lecteurs réseau (Y: et Z:)
├─ 11:00 - Script 09 (optionnel) : Signatures et ADCS
└─ 12:00 - Test sur 5 clients Windows 10 (DHCP et logon)
```

---

## ANALYSE DÉTAILLÉE DES SCRIPTS

### 📌 SCRIPT 01 : Configuration réseau (3 versions : BRUXELLE, NAMUR, MONS)

**Ce qu'il fait :**
1. Configure l'adresse IP statique
2. Configure le serveur DNS
3. Renomme le serveur
4. Redémarre le serveur

**Variables clés :**
```powershell
$ServerName = "DC-BRUXELLE"        # Nom unique pour chaque serveur
$IPAddress = "172.28.1.1"          # IP unique par site
$PrefixLength = 24                 # Toujours /24 (255.255.255.0)
$DNSServer = "127.0.0.1"           # BRUXELLE pointe sur lui-même
# ou
$DNSServer = "172.28.1.1"          # NAMUR/MONS pointent vers BRUXELLE
```

**Résultat :**
- ✅ Serveur a sa configuration IP
- ✅ Peut ping les autres serveurs
- ✅ Redémarrage automatique

**Durée :** ~1 minute + 5 min redémarrage

---

### 📌 SCRIPT 02A : Promotion DC Root (Bruxelle)

**Ce qu'il fait :**
1. Installe les rôles AD-Domain-Services, DNS, DHCP
2. Configure DHCP (scope 192.168.10.50-150)
3. Crée la forêt "Belgique.lan"
4. Redémarre

**Concepts clés :**

| Terme | Explication |
|-------|------------|
| **Forêt** | Conteneur global (racine du domaine) |
| **Domaine** | Belgique.lan = zone de sécurité unique |
| **Sites AD** | Groupes de DC selon localisation géographique |
| **DSRM** | Mode restauration (password admin mode sans domaine) |

**Résultat :**
- ✅ Forêt créée
- ✅ BRUXELLE = Premier DC (maître)
- ✅ DNS fonctionnel (Belgique.lan résolvable)
- ✅ DHCP configuré

**Durée :** ~15 minutes

---

### 📌 SCRIPT 02B : Promotion Replica (Namur)

**Ce qu'il fait :**
1. Installe les rôles AD-Domain-Services et DNS
2. Demande les credentials Belgique\Administrateur
3. Se connecte à DC-BRUXELLE.Belgique.lan
4. Crée un Replica du domaine (non-Master)
5. Ajoute le serveur au site "NAMUR"

**Hiérarchie de réplication :**
```
BRUXELLE (DC Root)
    ↓ Réplication unidirectionnelle
NAMUR (Replica)
    ↓ Réplication unidirectionnelle
MONS (RODC - Read-Only)
```

**Conditions :**
- ⚠️ NAMUR doit **pouvoir ping BRUXELLE**
- ⚠️ Routage 172.28.x.x ↔ 172.25.0.x doit fonctionner
- ⚠️ Credentials Belgique\Administrateur requis (créé lors du script 02A)

**Résultat :**
- ✅ NAMUR synchronisé avec BRUXELLE
- ✅ Tous les utilisateurs visibles sur NAMUR
- ✅ Fait partie de la même forêt

**Durée :** ~20 minutes

---

### 📌 SCRIPT 02C : Promotion RODC (Mons)

**Ce qu'il fait :**
1. Identique au 02B MAIS avec flag `-ReadOnlyReplica:$true`
2. Cache les mots de passe (réplication masquée)
3. Utilisateurs locaux peuvent se connecter même si lien principal coupé

**RODC = Read-Only Domain Controller**
```
DC Normal          vs      RODC
├─ Peut modifier AD        ├─ Lecture seule
├─ Full permissions        ├─ Pas de modifications
└─ Master de réplication   └─ Slave sans écriture
```

**Avantage :** Si DC-BRUXELLE tombe, MONS continue à authentifier les utilisateurs (mais en lecture seule)

**Durée :** ~20 minutes

---

### 📌 SCRIPT 03 : Import utilisateurs depuis CSV

**Ce qu'il fait :**
1. Lit le fichier CSV (Employes-Liste6.csv)
2. Parse chaque ligne et crée un utilisateur AD
3. Crée les OUs manquantes
4. Crée les groupes Global (GG_*) et Local (GL_*)
5. Remplit l'annuaire

**Parsing du CSV :**

```csv
Nom;Prénom;Description;Département;Nº Interne;Bureau
AIMANT;Rayan;Informaticien;HotLine/Informatique;326;Bureau 13
```

↓ Convertit en :

```powershell
$SamAccountName = "r.aimant"  # Prénom[0].Nom
$UserPrincipalName = "r.aimant@Belgique.lan"
$Path = "OU=HotLine,OU=Informatique,DC=Belgique,DC=lan"
$GroupName = "GG_HotLine" ou "GG_Informatique"
```

**Schéma OU créé :**
```
Si "HotLine/Informatique" :
  - OU Parent = Informatique
  - OU Enfant = HotLine
  - Utilisateur placé dans OU=HotLine,OU=Informatique

Si "Comptabilité/Finances" ou juste "Comptabilité" :
  - OU Parent = Finances
  - OU Enfant = Comptabilité ou aucun enfant
```

**Groupes créés (AGDLP) :**
```
GG_HotLine (Global) → GL_HotLine_RW (Domain Local)
```

**Résultat :**
- ✅ ~200+ utilisateurs créés
- ✅ OUs autom. structurées par département
- ✅ Groupes AGDLP en place
- ✅ Tous les utilisateurs appartiennent à leur groupe

**Durée :** ~5-10 minutes

---

### 📌 SCRIPT 04 : Installation serveur de fichiers

**Ce qu'il fait :**
1. Installe le rôle File Server Resource Manager
2. Crée l'arborescence C:\DossiersPartages
3. Crée les sous-dossiers (Commun, Departements, etc.)
4. Configure les partages SMB accessibles par le réseau

**Arborescence créée :**
```
C:\DossiersPartages
├── Commun/              (Partagé : \\Serveur\DossiersPartages)
├── Departements/
│   ├── Ressources humaines/
│   │   ├── Gestion du personnel/
│   │   └── Recrutement/
│   ├── R&D/
│   │   ├── Recherche/
│   │   └── Testing/
│   └── ... (autres départements)
└── Quotas/              (Pour les templates)
```

**Partages SMB créés :**
```
\\Serveur\DossiersPartages
```

**Résultat :**
- ✅ Dossiers créés
- ✅ Partage accessible
- ✅ Permissions NTFS à configurer (Script 05)

**Durée :** ~2 minutes

---

### 📌 SCRIPT 05 : Configuration permissions NTFS

**Ce qu'il fait :**
1. Pour chaque OU (Département/Sous-département)
2. Applique les permissions NTFS
3. Crée les groupes managés GG_*
4. Ajoute les permissions selon la hiérarchie

**Modèle de permissions :**

```
Dossier Ressources humaines/
├─ Tous les RH (GG_Ressources humaines) : Read
├─ Responsables RH (Groupe spécial) : Modify/FullControl
└─ Direction (GG_DIRECTION) : FullControl

Sous-dossier Gestion du personnel/
├─ Utilisateurs Gestion (GG_Gestion du personnel) : Modify
├─ Utilisateurs Recrutement (GG_Recrutement) : Read
└─ Direction : FullControl
```

**Concepts NTFS :**
```
Permissions = Droits d'accès aux fichiers
Héritage = Permissions enfant héritent du parent
ContainerInherit = S'applique aux sous-dossiers
ObjectInherit = S'applique aux fichiers
```

**Résultat :**
- ✅ Chaque département accède uniquement à ses dossiers
- ✅ Direction a accès à tout
- ✅ Permissions d'héritage en place

**Durée :** ~5 minutes

---

### 📌 SCRIPT 06 : Configuration quotas

**Ce qu'il fait :**
1. Crée les modèles de quota :
   - **Limit_500Mo** : Pour dossiers départements (parent)
   - **Limit_100Mo** : Pour sous-départements
2. Applique les quotas
3. Configure les alertes (80%, 90%, 100%)

**Quotas appliqués :**

| Niveau | Limite | Alerte |
|--------|--------|--------|
| Dossier Commun | 500 Mo | 80%/90%/100% → Email + EventLog |
| Département (parent) | 500 Mo | 80%/90%/100% → Email + EventLog |
| Sous-département | 100 Mo | 80%/90%/100% → Email + EventLog |

**Résultat :**
- ✅ Utilisateurs ne peuvent pas dépasser la limite
- ✅ Administrateur reçoit alertes email
- ✅ Logs dans Event Viewer

**Durée :** ~2 minutes

---

### 📌 SCRIPT 07 : Filtrage de fichiers

**Ce qu'il fait :**
1. Crée un groupe de fichiers : **Blocage_Sauf_Office_Images**
2. Autorise UNIQUEMENT : .docx, .xlsx, .pptx, .pdf, .jpg, .png, .txt, .doc, .xls
3. Bloque TOUT LE RESTE (.exe, .rar, .zip, .mp4, etc.)
4. Les blocages sont loggés dans Event Viewer

**Fichiers autorisés :**
```
✅ .docx (Word)
✅ .xlsx (Excel)
✅ .pptx (PowerPoint)
✅ .pdf  (Portable Doc)
✅ .jpg, .png (Images)
✅ .txt (Texte)

❌ .exe, .bat, .com (Exécutables → Sécurité)
❌ .rar, .zip, .7z (Archives)
❌ .mp4, .avi (Vidéos)
❌ .dll, .sys (Système)
```

**Résultat :**
- ✅ Sécurité malware améliorée
- ✅ Dépôt de fichiers malveillants bloqué
- ✅ Logs de tentatives dans Event Viewer

**Durée :** ~1 minute

---

### 📌 SCRIPT 08 : Configuration des GPO

**Ce qu'il fait :**

#### 8.1 Activation Corbeille AD
```powershell
Enable-ADOptionalFeature 'Recycle Bin Feature'
# Permet de restaurer des objets AD supprimés pendant 180 jours
```

#### 8.2 Script de logon (Mappage lecteurs)
```powershell
# Crée un script PowerShell qui s'exécute à chaque logon
# Montage automatique :
# Z: = \\Serveur\DossiersPartages\Commun (pour tous)
# Y: = \\Serveur\DossiersPartages\Departements\MonDepartement (par groupe)
```

#### 8.3 GPO "Employes Standard"
```
Restrictions appliquées à TOUS les utilisateurs (sauf Admin/IT) :

✅ Fond d'écran = Image de la société
✅ Redirection "Mes documents" vers Z:\Documents
✅ Installation Office (déploiement via GPO)
✅ Nettoyage Start Menu (supprime jeux, apps inutiles)

❌ Bloquer : Panneau de configuration
❌ Bloquer : Invite de commande (cmd.exe)
❌ Bloquer : Éditeur de registre (regedit.exe)
```

#### 8.4 Exclusions
```
Groupe "INFORMATIQUE/Systèmes" :
├─ AUTORISÉ : Panneau de configuration
├─ AUTORISÉ : Invite de commande
├─ AUTORISÉ : Édition du registre
└─ Administrateurs locaux de leurs machines
```

**Résultat :**
- ✅ Lecteurs réseau montés automatiquement
- ✅ Interface standardisée
- ✅ Sécurité accrue (cmd bloquée)

**Durée :** ~5-10 minutes

---

### 📌 SCRIPT 09 (Optionnel) : Certificats et signature PowerShell

**Ce qu'il fait :**
1. Installe ADCS (Active Directory Certificate Services)
2. Crée un certificat d'entreprise
3. Crée et signe un script PowerShell
4. Configure GPO "AllSigned" (tous les scripts doivent être signés)

**Avantage :**
```
Scripts non signés → Bloqués
Scripts signés par Admin → Exécutés
Scripts signés par inconnu → Bloqués
```

**Durée :** ~10 minutes (optionnel)

---

## TROUBLESHOOTING

### ❌ Erreur : "Impossible de se connecter à DC-BRUXELLE"

**Causes possibles :**
1. Routage réseau bloqué (firewall)
2. Serveurs ne peuvent pas se ping
3. DNS non configuré

**Solutions :**
```powershell
# Sur NAMUR, tester :
ping 172.28.1.1
ping DC-BRUXELLE.Belgique.lan   # Doit résoudre

# Si ping OK mais DC-BRUXELLE.Belgique.lan échoue :
# → Vérifier DNS sur NAMUR (doit pointer vers 172.28.1.1 APRÈS que Bruxelle soit DC)

# Vérifier AD depuis NAMUR :
Get-ADForest
# Doit afficher Belgique.lan
```

### ❌ Erreur : "Le fichier CSV n'a pas été trouvé"

**Cause :**
Le script cherche `C:\Install\Employes-Liste6.csv` mais le fichier est ailleurs

**Solution :**
```powershell
# Créer le dossier
New-Item -Path "C:\Install" -ItemType Directory -Force

# Copier le CSV
Copy-Item -Path "\\Serveur\Partage\Employes-Liste6.csv" -Destination "C:\Install\"

# Ou mettre à jour le chemin dans le script :
$CsvPath = "E:\Temp\Employes-Liste6.csv"  # Adapter au vrai chemin
```

### ❌ Erreur : "Impossible de créer le partage SMB"

**Cause :**
Droits insuffisants ou disque C: plein

**Solution :**
```powershell
# Vérifier droits Admin
whoami /groups | find "S-1-5-32-544"  # Doit afficher "Administrators"

# Vérifier espace disque
Get-Volume C: | Select-Object SizeRemaining

# Créer manuellement :
New-SmbShare -Name "DossiersPartages" -Path "C:\DossiersPartages" -FullAccess "Everyone"
```

### ❌ Erreur : "Les utilisateurs ne se connectent pas"

**Causes :**
1. DHCP pas configuré
2. DNS ne résout pas Belgique.lan
3. Compte utilisateur désactivé

**Solutions :**
```powershell
# Vérifier DHCP
Get-DhcpServerv4Scope

# Tester DNS
Resolve-DnsName belgique.lan

# Vérifier utilisateur
Get-ADUser "r.aimant" | Select-Object Enabled, LockedOut
# Doit afficher Enabled=True, LockedOut=False
```

### ⚠️ Attention : Ordre d'exécution CRITIQUE

```
❌ ERREUR FRÉQUENTE : Lancer Script 02B (NAMUR) avant que 02A (BRUXELLE) soit terminé
   → La forêt n'existe pas → Failure !

✅ BON ORDRE :
1. Bruxelle : Script 01 → Script 02A → Attendre redémarrage complet
2. Namur   : Script 01 → Attendre redémarrage → Script 02B
3. Mons    : Script 01 → Attendre redémarrage → Script 02C
4. Bruxelle: Script 03 (import users)
5. Bruxelle: Scripts 04-09 (serveur fichiers + GPO)
```

---

## 📝 CHECKLIST AVANT DE COMMENCER

- [ ] Infrastructure physique testée (serveurs accessibles)
- [ ] Switch VLAN configuré et fonctionnel
- [ ] Firewall permet trafic 172.28.x.x ↔ 172.25.0.x
- [ ] Tous les serveurs ont déjà Windows Server 2019 installé
- [ ] Tous les serveurs configurés en IP statique temporaire
- [ ] Fichier CSV (Employes-Liste6.csv) téléchargé
- [ ] Scripts PowerShell téléchargés sur chaque serveur
- [ ] Test ping entre serveurs réussi

---

## ✅ CHECKLIST APRÈS CHAQUE ÉTAPE

### Après Script 01 (Config IP)
- [ ] `ipconfig /all` affiche la bonne IP
- [ ] Serveur a été renommé
- [ ] Serveur a redémarré

### Après Script 02A (DC Root)
- [ ] `whoami` retourne `BELGIQUE\Administrateur`
- [ ] `nslookup belgique.lan` résout
- [ ] `Get-ADForest` fonctionne

### Après Script 02B (Replica)
- [ ] `whoami` retourne `BELGIQUE\Administrateur`
- [ ] `Get-ADDomainController` affiche 2 contrôleurs
- [ ] Utilisateurs visibles : `Get-ADUser -Filter *`

### Après Script 02C (RODC)
- [ ] 3 DC visibles : `Get-ADDomainController`
- [ ] MONS en Read-Only : `Get-ADDomainController -Filter {Name -eq "DC-MONS-RO"}`

### Après Script 03 (Import users)
- [ ] `Get-ADUser -Filter * | Measure-Object` > 200
- [ ] OUs créées : `Get-ADOrganizationalUnit -Filter * | Count`
- [ ] Groupes créés : `Get-ADGroup -Filter * | Count`

### Après Scripts 04-07 (Fichiers)
- [ ] `Test-Path C:\DossiersPartages` = True
- [ ] Partage accessible : `net use x: \\127.0.0.1\DossiersPartages`
- [ ] Quotas appliqués : `Get-FsrmQuota`
- [ ] Filtres actifs : `Get-FsrmFileScreen`

---

## 📞 SUPPORT

Pour les erreurs PowerShell, consultez les logs :
```powershell
# Logs système
Get-EventLog -LogName System -Newest 10

# Logs AD
Get-EventLog -LogName "Directory Service" -Newest 10

# Logs PowerShell
$PROFILE  # Voir le chemin du profil

# Logs installation rôles
dir C:\Windows\Logs\
```

---

**Durée totale estimée : 2-3 jours de travail effectif**

Bonne implémentation ! 🚀