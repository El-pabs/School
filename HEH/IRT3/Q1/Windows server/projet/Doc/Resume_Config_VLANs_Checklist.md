# 📊 RÉSUMÉ DE CONFIGURATION - VLANs et Infrastructure

## 🌐 NOMS ET CONFIGURATION DES VLANs

Selon le cahier des charges, vos VLANs doivent être structurés par **département + fonction**.

### 📍 VLANs Recommandés (Adresse : 172.28.x.0/24)

| VLAN ID | Nom | Adresse Réseau | DHCP Plage | Département | Utilisateurs |
|---------|-----|--------|---------|-----|----------|
| **10** | VLAN-Admin | 172.28.10.0/24 | 172.28.10.50-150 | Direction, RH, Finances | ~50 |
| **20** | VLAN-RD | 172.28.20.0/24 | 172.28.20.50-150 | R&D (Recherche, Testing) | ~50 |
| **30** | VLAN-IT | 172.28.30.0/24 | 172.28.30.50-150 | Informatique (HotLine, Dev, Sys) | ~50 |
| **40** | VLAN-Commercial | 172.28.40.0/24 | 172.28.40.50-150 | Marketing (Sites 1-4), Commerciaux | ~60 |
| **50** | VLAN-Technique | 172.28.50.0/24 | 172.28.50.50-150 | Technique (Achat, Techniciens) | ~30 |
| **99** | VLAN-VoIP | 172.28.99.0/24 | 172.28.99.50-150 | Téléphones IP | ~100 |

### 🔐 Serveurs (En dehors des VLANs clients)

| Serveur | IP | Subnet | Rôle | VLAN |
|---------|-------|--------|------|------|
| DC-BRUXELLE | 172.28.1.1 | 172.28.0.0/16 | Master | Native/Management |
| DC-NAMUR | 172.25.0.1 | 172.25.0.0/16 | Replica | Distant |
| DC-MONS-RO | 172.28.2.1 | 172.28.0.0/16 | RODC | Native/Management |

---

## 🏗️ STRUCTURE AD (Active Directory)

### Structure des OUs après import

```
DC=Belgique,DC=lan
├── OU=Direction (Groupe: GG_DIRECTION)
├── OU=Ressources humaines
│   ├── OU=Gestion du personnel (Groupe: GG_GestionDuPersonnel)
│   └── OU=Recrutement (Groupe: GG_Recrutement)
├── OU=R&D
│   ├── OU=Recherche (Groupe: GG_Recherche)
│   └── OU=Testing (Groupe: GG_Testing)
├── OU=Finances
│   ├── OU=Comptabilité (Groupe: GG_Comptabilite)
│   └── OU=Investissements (Groupe: GG_Investissements)
├── OU=Informatique
│   ├── OU=HotLine (Groupe: GG_HotLine)
│   ├── OU=Développement (Groupe: GG_Developpement)
│   └── OU=Systèmes (Groupe: GG_Systemes)
├── OU=Technique
│   ├── OU=Achat (Groupe: GG_Achat)
│   └── OU=Techniciens (Groupe: GG_Techniciens)
├── OU=Marketting
│   ├── OU=Site1 (Groupe: GG_Site1)
│   ├── OU=Site2 (Groupe: GG_Site2)
│   ├── OU=Site3 (Groupe: GG_Site3)
│   └── OU=Site4 (Groupe: GG_Site4)
├── OU=Commerciaux
│   ├── OU=Sédentaires (Groupe: GG_Sedentaires)
│   └── OU=Technico (Groupe: GG_Technico)
└── OU=Computers
    ├── OU=VLAN10
    ├── OU=VLAN20
    ├── OU=VLAN30
    ├── OU=VLAN40
    ├── OU=VLAN50
    └── OU=VLAN99
```

---

## 📋 CHECKLIST PRÉ-IMPLÉMENTATION

### Infrastructure physique
- [ ] Switch VLAN supportant VLANs 10, 20, 30, 40, 50, 99
- [ ] Firewall/Routeur permettant trafic entre 172.28.x.x et 172.25.0.x
- [ ] 3 serveurs Windows Server 2019 avec disque C: ≥ 50 GB
- [ ] Accès console (écran/clavier) sur chaque serveur
- [ ] Connectivité réseau testée entre les 3 serveurs

### Fichiers nécessaires
- [ ] `Scripts_01_Config_Reseau.ps1`
- [ ] `Scripts_02_Promotion_DC.ps1`
- [ ] `Script_03_Import_Utilisateurs.ps1`
- [ ] `Script_04-07_Serveur_Fichiers.ps1`
- [ ] `Script_08-09_GPO_WebServer.ps1`
- [ ] `Employes-Liste6_ADAPTEE.csv`
- [ ] Tous les fichiers sur clé USB ou partage

### Documentation
- [ ] Guide_Complet_Implementation.md (lu et compris)
- [ ] Procedure_Execution_Detaillee.md (à proximité)
- [ ] Résumé_Configuration_VLANs.md (ce document)

---

## ✅ CHECKLIST POST-IMPLÉMENTATION

### Jour 1 : Après scripts 01 (Configuration réseau)

- [ ] Bruxelle : IP = 172.28.1.1, nom = DC-BRUXELLE
- [ ] Namur : IP = 172.25.0.1, nom = DC-NAMUR
- [ ] Mons : IP = 172.28.2.1, nom = DC-MONS-RO
- [ ] Ping 172.28.1.1 depuis Namur réussit
- [ ] Ping 172.28.1.1 depuis Mons réussit
- [ ] Routage 172.28.x.x ↔ 172.25.0.x fonctionne

### Jour 2 : Après scripts 02 (Promotion DC)

- [ ] Bruxelle : `whoami` = BELGIQUE\Administrateur
- [ ] Bruxelle : `Get-ADForest` affiche Belgique.lan
- [ ] Namur : `whoami` = BELGIQUE\Administrateur
- [ ] Namur : `Get-ADDomainController` affiche 2 DC (Bruxelle, Namur)
- [ ] Mons : `whoami` = BELGIQUE\Administrateur
- [ ] Mons : `Get-ADDomainController` affiche 3 DC
- [ ] DHCP actif : `Get-DhcpServerv4Scope` affiche 6 scopes
- [ ] DNS fonctionnel : `Resolve-DnsName belgique.lan` réussit

### Jour 3 : Après script 03 (Import utilisateurs)

- [ ] `Get-ADUser -Filter * | Measure-Object` > 200
- [ ] `Get-ADOrganizationalUnit -Filter * | Measure-Object` > 15
- [ ] `Get-ADGroup -Filter * | Measure-Object` > 30
- [ ] Test utilisateur : `Get-ADUser "r.aimant"` fonctionne
- [ ] OUs correctes pour chaque département

### Jour 4 : Après script 04-07 (Serveur fichiers)

- [ ] `Test-Path C:\DossiersPartages` = True
- [ ] Partage accessible : `net view \\DC-BRUXELLE`
- [ ] `Get-FsrmQuota | Measure-Object` > 10
- [ ] `Get-FsrmFileScreen | Measure-Object` > 0
- [ ] Test client : `net use x: \\DC-BRUXELLE\DossiersPartages` réussit

### Jour 5 : Après scripts 08-09 (GPO + Web)

- [ ] `Get-GPO -All | Measure-Object` > 2
- [ ] GPO liées aux OUs : `Get-GPLink -Target "DC=Belgique,DC=lan"` affiche liaisons
- [ ] Corbeille AD activée
- [ ] IIS installé : `Get-WebBinding`
- [ ] Certificat SSL créé
- [ ] Accès HTTPS : https://www.Belgique.lan fonctionne

---

## 🔍 TESTS DE VALIDATION

### Test 1 : Réplication AD (Sur n'importe quel DC)
```powershell
Get-ADDomainController
# Résultat : DC-BRUXELLE, DC-NAMUR, DC-MONS-RO
```

### Test 2 : DHCP (Sur Bruxelle)
```powershell
Get-DhcpServerv4Scope
# Résultat : 6 scopes (VLAN10 à VLAN50 + VoIP99)
```

### Test 3 : Utilisateurs (Depuis client Windows 10 joint au domaine)
```powershell
whoami
# Résultat : BELGIQUE\r.aimant (ou autre utilisateur)
```

### Test 4 : Partages (Depuis client)
```powershell
net use x: \\DC-BRUXELLE\DossiersPartages
dir x:\
# Résultat : Dossiers "Commun" et "Departements"
```

### Test 5 : GPO (Depuis client)
```powershell
gpupdate /force
gpresult /H rapport.html
# Vérifier que GPO_Employes_Standard est appliquée
```

### Test 6 : RODC (Sur DC-MONS-RO)
```powershell
Get-ADDomainController -Identity DC-MONS-RO | Select-Object IsReadOnly
# Résultat : True
```

---

## 🎯 OBJECTIFS ACCOMPLISSEMENT

Après tous les scripts, vous avez :

### ✅ Infrastructure système
- [x] 3 contrôleurs de domaine répliqués
- [x] Forêt Belgique.lan opérationnel
- [x] DNS résolvant belgique.lan
- [x] DHCP pour 6 VLANs

### ✅ Annuaire Active Directory
- [x] ~200 utilisateurs importés
- [x] Structure d'OUs par département
- [x] Groupes AGDLP configurés
- [x] Permissions NTFS appliquées

### ✅ Serveur de fichiers
- [x] Partage \\DC-BRUXELLE\DossiersPartages
- [x] Arborescence par département
- [x] Quotas (500 Mo parent, 100 Mo enfant)
- [x] Filtrage fichiers (Office + images autorisés)

### ✅ Gestion centralisée
- [x] GPO restrictive appliquée
- [x] Corbeille AD activée (180 jours)
- [x] Montage automatique lecteurs Y: et Z:
- [x] Serveur Web HTTPS fonctionnel

### ✅ Sécurité
- [x] Mots de passe complexes définis
- [x] Informatique exclue des restrictions
- [x] RODC pour authentification locale (Mons)
- [x] Certificat SSL pour serveur Web

---

## 📱 CONFIGURATION CLIENT WINDOWS 10

### Avant de connecter un client au domaine

**Sur le client :**

1. **Rejoindre le domaine :**
   ```powershell
   # Paramètres > Système > Informations système > Modifier les paramètres
   # OU via PowerShell :
   Add-Computer -DomainName belgique.lan -Credential belgique\administrateur -Restart
   ```

2. **DHCP automatique :**
   - Le client reçoit automatiquement une IP (172.28.x.50-150)
   - En fonction du VLAN, il reçoit de différents scopes

3. **Connexion utilisateur :**
   ```
   Nom d'utilisateur: belgique\r.aimant
   Mot de passe: P@ssword2025! (puis changé à première connexion)
   ```

4. **Vérification :**
   ```powershell
   whoami
   # Résultat : BELGIQUE\r.aimant
   
   Get-PSDrive
   # Résultat : Y: et Z: montées automatiquement
   ```

---

## 📞 SUPPORT

Pour chaque composant, consultez :

```powershell
# Active Directory
Get-Help Get-ADUser -Full
Get-Help Get-ADGroup -Full

# DHCP
Get-Help Get-DhcpServerv4Scope -Full
Get-Help Add-DhcpServerv4Scope -Full

# GPO
Get-Help Get-GPO -Full
Get-Help New-GPLink -Full

# File Server
Get-Help Get-FsrmQuota -Full
Get-Help New-SmbShare -Full

# Événements système
Get-EventLog -LogName System -Newest 10
Get-EventLog -LogName "Directory Service" -Newest 10
```

---

## 🎓 POUR ALLER PLUS LOIN

### Points d'amélioration possible

1. **Haute disponibilité**
   - Ajouter un 4e DC en standby
   - Configurer la réplication multi-sites

2. **Sauvegarde**
   - Implémenter Windows Server Backup
   - Sauvegarder l'état système des DC

3. **Monitoring**
   - Installer Nagios/Zabbix
   - Alertes SNMP sur les DC

4. **Sécurité avancée**
   - ADCS (Certificats d'entreprise)
   - BitLocker sur les disques
   - Audit détaillé des accès fichiers

5. **Optimisation DHCP**
   - Failover DHCP entre Bruxelle et Namur
   - Scopes supplémentaires pour VoIP

---

**Documentation complète fournie : 3 documents (Guide, Procédure, Résumé)**

**Bon déploiement ! 🚀**