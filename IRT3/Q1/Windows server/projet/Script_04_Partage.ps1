$RootPath = "C:\Share"
$Domain = "Belgique.lan"
$DomainDN = "DC=Belgique,DC=lan"
$CSVPath = "C:\users\Administrator\Downloads\Employes-Liste6_ADAPTEE.csv"
$ComputerName = $env:COMPUTERNAME
$AdminGroup = "BUILTIN\Administrators"

Write-Host "AGDLP COMPLET - v17 (FORCE ADMIN ACCESS)" -ForegroundColor Cyan
Write-Host "Domain: $Domain" -ForegroundColor Cyan
Write-Host "Computer: $ComputerName" -ForegroundColor Cyan

# --- [0] PRE-REQUIS : ACTIVER PRIVILEGES ---
Write-Host "`n[0/11] Activation des privileges administrateur..." -ForegroundColor Yellow
$Definition = @"
using System;
using System.Runtime.InteropServices;
public class TokenManipulator
{
    [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
    internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);
    [DllImport("kernel32.dll", ExactSpelling = true)]
    internal static extern IntPtr GetCurrentProcess();
    [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
    internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
    [DllImport("advapi32.dll", SetLastError = true)]
    internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    internal struct TokPriv1Luid
    {
        public int Count;
        public long Luid;
        public int Attr;
    }
    internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
    internal const int TOKEN_QUERY = 0x00000008;
    internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
    public static bool AddPrivilege(string privilege)
    {
        try
        {
            bool retVal;
            TokPriv1Luid tp;
            IntPtr hproc = GetCurrentProcess();
            IntPtr htok = IntPtr.Zero;
            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
            tp.Count = 1;
            tp.Luid = 0;
            tp.Attr = SE_PRIVILEGE_ENABLED;
            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
            return retVal;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}
"@
Add-Type $Definition
[TokenManipulator]::AddPrivilege("SeRestorePrivilege") | Out-Null
[TokenManipulator]::AddPrivilege("SeBackupPrivilege") | Out-Null
[TokenManipulator]::AddPrivilege("SeTakeOwnershipPrivilege") | Out-Null
Write-Host "Privileges SeRestore/SeBackup/SeTakeOwnership actives." -ForegroundColor Green

# --- [1] CREER LES DOSSIERS ---
Write-Host "`n[1/11] Creation de la structure de dossiers..." -ForegroundColor Yellow

$Structure = @{
    "Ressources humaines" = @{
        "Gestion du personnel" = "romain.marcel"
        "Recrutement"          = "francois.bellante"
    }
    "Finances" = @{
        "Comptabilité"    = "geoffrey.craeyé"
        "Investissements" = "jason.paris"
    }
    "Informatique" = @{
        "Développement" = "adrien.bavouakenfack"
        "HotLine"       = "victor.quicken"
        "Systèmes"      = "arnaud.baisagurova"
    }
    "R&D" = @{
        "Recherche" = "lorraine.al-khamry"
        "Testing"   = "emilie.bayanaknlend"
    }
    "Technique" = @{
        "Achat"       = "ruben.alaca"
        "Techniciens" = "geoffrey.chiarelli"
    }
    "Commerciaux" = @{
        "Sédentaires" = "dorcas.balci"
        "Technico"    = "adriano.cambier"
    }
    "Marketting" = @{
        "Site1" = "remi.brodkom"
        "Site2" = "simon.amand"
        "Site3" = "vincent.aubly"
        "Site4" = "audrey.brogniez"
    }
}

if (-not (Test-Path $RootPath)) {
    New-Item -ItemType Directory -Path $RootPath -Force | Out-Null
    Write-Host "Dossier racine cree: $RootPath"
}

$CommonPath = Join-Path $RootPath "Commun"
if (-not (Test-Path $CommonPath)) {
    New-Item -ItemType Directory -Path $CommonPath -Force | Out-Null
    Write-Host "Dossier cree: Commun"
}

foreach ($Category in $Structure.Keys) {
    $CategoryPath = Join-Path $RootPath $Category
    
    if (-not (Test-Path $CategoryPath)) {
        New-Item -ItemType Directory -Path $CategoryPath -Force | Out-Null
        Write-Host "Dossier cree: $Category"
    }
    
    foreach ($SubDept in $Structure[$Category].Keys) {
        $SubPath = Join-Path $CategoryPath $SubDept
        
        if (-not (Test-Path $SubPath)) {
            New-Item -ItemType Directory -Path $SubPath -Force | Out-Null
            Write-Host "Dossier cree: $Category\$SubDept"
        }
    }
}

# --- FONCTION FORCE PERMISSIONS ---
function Force-AdminAccess {
    param([string]$Path)
    
    Write-Host "  🔧 Force Admin Access sur: $(Split-Path -Leaf $Path)" -ForegroundColor Gray
    
    try {
        # 1. Prendre possession (Take Ownership)
        $Acl = Get-Acl $Path
        $AdminUser = New-Object System.Security.Principal.NTAccount("Administrators")
        $Acl.SetOwner($AdminUser)
        Set-Acl -Path $Path -AclObject $Acl
        
        # 2. Ajouter Full Control pour Admins
        $Acl = Get-Acl $Path
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "Administrators",
            "FullControl",
            "ContainerInherit, ObjectInherit",
            "None",
            "Allow"
        )
        $Acl.AddAccessRule($AccessRule)
        Set-Acl -Path $Path -AclObject $Acl
        
    } catch {
        Write-Host "    ⚠️ Erreur Force Admin: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Appliquer Force Admin sur TOUTE la structure
Force-AdminAccess -Path $RootPath
Force-AdminAccess -Path $CommonPath

foreach ($Category in $Structure.Keys) {
    $CategoryPath = Join-Path $RootPath $Category
    Force-AdminAccess -Path $CategoryPath
    
    foreach ($SubDept in $Structure[$Category].Keys) {
        $SubPath = Join-Path $CategoryPath $SubDept
        Force-AdminAccess -Path $SubPath
    }
}

Write-Host "Dossiers et accès Admin: OK"

# --- [2] CHARGER LES UTILISATEURS ---
Write-Host "`n[2/11] Chargement des utilisateurs..." -ForegroundColor Yellow
$Users = Import-Csv -Path $CSVPath -Delimiter ";" -Encoding UTF8
Write-Host "Utilisateurs charges: $($Users.Count)"

# --- [3] VALIDER LES RESPONSABLES DANS AD ---
Write-Host "`n[3/11] Validation des responsables dans AD..." -ForegroundColor Yellow

$ValidManagers = @{}
foreach ($Category in $Structure.Keys) {
    foreach ($SubDept in $Structure[$Category].Keys) {
        $ManagerFromStructure = $Structure[$Category][$SubDept]
        
        $AdUser = $null
        try {
            $AdUser = Get-ADUser -Filter "SamAccountName -eq '$ManagerFromStructure'" -ErrorAction SilentlyContinue
        } catch { }
        
        if ($AdUser) {
            $ValidManagers["$Category|$SubDept"] = $AdUser.SamAccountName
            Write-Host "OK Responsable valide: $Category > $SubDept = $($AdUser.SamAccountName)" -ForegroundColor Green
        } else {
            Write-Host "MISSING Responsable: $Category > $SubDept = $ManagerFromStructure" -ForegroundColor Red
            $ValidManagers["$Category|$SubDept"] = $null
        }
    }
}

# --- [4] CREER LES GROUPES GLOBAUX (A > G) ---
Write-Host "`n[4/11] Creation des groupes globaux (A > G)..." -ForegroundColor Yellow

foreach ($Category in $Structure.Keys) {
    foreach ($SubDept in $Structure[$Category].Keys) {
        $GlobalGroupName = "GG_$SubDept"
        
        $ExistingGroup = Get-ADGroup -Filter "SamAccountName -eq '$GlobalGroupName'" -ErrorAction SilentlyContinue
        
        if (-not $ExistingGroup) {
            try {
                New-ADGroup -SamAccountName $GlobalGroupName -Name $GlobalGroupName `
                    -GroupScope Global -GroupCategory Security `
                    -DisplayName "Global - $SubDept" `
                    -Description "Groupe global: Utilisateurs de $SubDept" `
                    -Path $DomainDN -Confirm:$false
                Write-Host "Groupe global cree: $GlobalGroupName"
            } catch {
                Write-Host "ERREUR creation GG: $GlobalGroupName - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

$ExistingDir = Get-ADGroup -Filter "SamAccountName -eq 'GG_Direction'" -ErrorAction SilentlyContinue
if (-not $ExistingDir) {
    try {
        New-ADGroup -SamAccountName "GG_Direction" -Name "GG_Direction" `
            -GroupScope Global -GroupCategory Security `
            -DisplayName "Global - Direction" `
            -Description "Groupe global: Direction" `
            -Path $DomainDN -Confirm:$false
        Write-Host "Groupe global cree: GG_Direction"
    } catch {
        Write-Host "ERREUR creation GG_Direction - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n[4b/11] Configuration Fine-Grained Password Policy (PSO) pour Direction...`n" -ForegroundColor Magenta

# Variables PSO
$PSOName = "PSO_Direction_15chars"
$PSOPrecedence = 1  # Plus bas = priorité plus haute
$MinPasswordLength = 15
$MinComplexity = $true
$MaxPasswordAge = 0  # jours
$MinPasswordAge = 1   # jour
$PasswordHistoryCount = 24  # nombre de anciens mots de passe à mémoriser

# Vérifier si la PSO existe déjà
$ExistingPSO = Get-ADFineGrainedPasswordPolicy -Filter "Name -eq '$PSOName'" -ErrorAction SilentlyContinue

if (-not $ExistingPSO) {
    Write-Host "✅ Creation de la PSO: $PSOName" -ForegroundColor Cyan
    
    try {
        # Créer la PSO avec les paramètres stricts pour Direction
        New-ADFineGrainedPasswordPolicy `
            -Name $PSOName `
            -Precedence $PSOPrecedence `
            -DisplayName "PSO Direction - 15 caractères minimum" `
            -Description "Fine-Grained Password Policy pour groupe Direction - Cahier des charges compliance" `
            -MinPasswordLength $MinPasswordLength `
            -ComplexityEnabled $MinComplexity `
            -MaxPasswordAge (New-TimeSpan -Days $MaxPasswordAge) `
            -MinPasswordAge (New-TimeSpan -Days $MinPasswordAge) `
            -PasswordHistoryCount $PasswordHistoryCount `
            -LockoutDuration (New-TimeSpan -Minutes 30) `
            -LockoutObservationWindow (New-TimeSpan -Minutes 30) `
            -LockoutThreshold 5 `
            -ProtectedFromAccidentalDeletion $true `
            -Confirm:$false
        
        Write-Host "✅ PSO creee avec succes" -ForegroundColor Green
        Write-Host "   ├─ Precedence: $PSOPrecedence (haute priorite)" -ForegroundColor Gray
        Write-Host "   ├─ Min password: $MinPasswordLength caracteres" -ForegroundColor Gray
        Write-Host "   ├─ Complexite: ACTIVEE" -ForegroundColor Gray
        Write-Host "   ├─ Max age password: $MaxPasswordAge jours" -ForegroundColor Gray
        Write-Host "   ├─ Historique: $PasswordHistoryCount mots de passe" -ForegroundColor Gray
        Write-Host "   └─ Lockout: 5 tentatives / 30 minutes" -ForegroundColor Gray
        
    } catch {
        Write-Host "❌ ERREUR creation PSO: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "✅ PSO existe deja: $PSOName" -ForegroundColor Green
}

# Appliquer la PSO au groupe Direction
Write-Host "`n✅ Application de la PSO au groupe GG_Direction..." -ForegroundColor Cyan

try {
    # Récupérer le groupe Direction
    $GGDirection = Get-ADGroup -Filter "SamAccountName -eq 'GG_Direction'" -ErrorAction SilentlyContinue
    
    if ($GGDirection) {
        # Récupérer la PSO
        $PSO = Get-ADFineGrainedPasswordPolicy -Filter "Name -eq '$PSOName'" -ErrorAction SilentlyContinue
        
        if ($PSO) {
            # Appliquer la PSO au groupe
            Add-ADFineGrainedPasswordPolicySubject -Identity $PSO -Subjects $GGDirection -Confirm:$false
            Write-Host "✅ PSO appliquee au groupe GG_Direction" -ForegroundColor Green
        } else {
            Write-Host "⚠️  PSO non trouvee pour application" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  Groupe GG_Direction non trouve" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "⚠️  Note: PSO deja appliquee ou groupe vide - $($_.Exception.Message)" -ForegroundColor Yellow
}

# Vérification de la PSO appliquée
Write-Host "`n✅ Verification des PSO actuelles:" -ForegroundColor Cyan

try {
    $AllPSO = Get-ADFineGrainedPasswordPolicy -Filter * -ErrorAction SilentlyContinue
    
    foreach ($Policy in $AllPSO) {
        Write-Host "  ├─ PSO: $($Policy.Name)" -ForegroundColor Gray
        Write-Host "  │  ├─ Precedence: $($Policy.Precedence)" -ForegroundColor Gray
        Write-Host "  │  ├─ Min chars: $($Policy.MinPasswordLength)" -ForegroundColor Gray
        Write-Host "  │  ├─ Complexite: $($Policy.ComplexityEnabled)" -ForegroundColor Gray
        Write-Host "  │  ├─ Max age: $($Policy.MaxPasswordAge.Days) jours" -ForegroundColor Gray
        Write-Host "  │  └─ Appliquees a: $($(Get-ADFineGrainedPasswordPolicySubject -Identity $Policy -ErrorAction SilentlyContinue | Measure-Object).Count) groupes" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ⚠️  Impossible d'afficher les PSO: $($_.Exception.Message)" -ForegroundColor Yellow
}


# --- [5] CREER LES GROUPES LOCAUX (G > L) ---
Write-Host "`n[5/11] Creation des groupes locaux de domaine (G > L)..." -ForegroundColor Yellow

$DLCommonRead = Get-ADGroup -Filter "SamAccountName -eq 'DL_Commun_R'" -ErrorAction SilentlyContinue
if (-not $DLCommonRead) {
    try {
        New-ADGroup -SamAccountName "DL_Commun_R" -Name "DL_Commun_R" `
            -GroupScope DomainLocal -GroupCategory Security `
            -DisplayName "Domain Local - Commun (Lecture)" `
            -Description "Groupe pour lecture Commun" `
            -Path $DomainDN -Confirm:$false
        Write-Host "Groupe local cree: DL_Commun_R"
    } catch {
        Write-Host "ERREUR creation DL_Commun_R - $($_.Exception.Message)" -ForegroundColor Red
    }
}

$DLCommonRW = Get-ADGroup -Filter "SamAccountName -eq 'DL_Commun_RW'" -ErrorAction SilentlyContinue
if (-not $DLCommonRW) {
    try {
        New-ADGroup -SamAccountName "DL_Commun_RW" -Name "DL_Commun_RW" `
            -GroupScope DomainLocal -GroupCategory Security `
            -DisplayName "Domain Local - Commun (R/W)" `
            -Description "Groupe pour R/W Commun" `
            -Path $DomainDN -Confirm:$false
        Write-Host "Groupe local cree: DL_Commun_RW"
    } catch {
        Write-Host "ERREUR creation DL_Commun_RW - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nCreation des DL pour les sous-depts (R ET RW)..." -ForegroundColor Cyan
foreach ($Category in $Structure.Keys) {
    foreach ($SubDept in $Structure[$Category].Keys) {
        
        $DLSubDeptRead = "DL_$($SubDept)_R"
        $DLSubDeptReadExisting = Get-ADGroup -Filter "SamAccountName -eq '$DLSubDeptRead'" -ErrorAction SilentlyContinue
        
        if (-not $DLSubDeptReadExisting) {
            try {
                New-ADGroup -SamAccountName $DLSubDeptRead -Name $DLSubDeptRead `
                    -GroupScope DomainLocal -GroupCategory Security `
                    -DisplayName "Domain Local - $SubDept (Read)" `
                    -Description "Groupe lecture pour $SubDept" `
                    -Path $DomainDN -Confirm:$false
                Write-Host "Groupe local cree: $DLSubDeptRead"
            } catch {
                Write-Host "ERREUR creation $DLSubDeptRead - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        $DLSubDeptRW = "DL_$($SubDept)_RW"
        $DLSubDeptRWExisting = Get-ADGroup -Filter "SamAccountName -eq '$DLSubDeptRW'" -ErrorAction SilentlyContinue
        
        if (-not $DLSubDeptRWExisting) {
            try {
                New-ADGroup -SamAccountName $DLSubDeptRW -Name $DLSubDeptRW `
                    -GroupScope DomainLocal -GroupCategory Security `
                    -DisplayName "Domain Local - $SubDept (R/W)" `
                    -Description "Groupe R/W pour $SubDept" `
                    -Path $DomainDN -Confirm:$false
                Write-Host "Groupe local cree: $DLSubDeptRW"
            } catch {
                Write-Host "ERREUR creation $DLSubDeptRW - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        $ManagerGroupName = "GG_Managers_$SubDept"
        $ManagerGroupExisting = Get-ADGroup -Filter "SamAccountName -eq '$ManagerGroupName'" -ErrorAction SilentlyContinue
        
        if (-not $ManagerGroupExisting) {
            try {
                New-ADGroup -SamAccountName $ManagerGroupName -Name $ManagerGroupName `
                    -GroupScope Global -GroupCategory Security `
                    -DisplayName "Global - Managers $SubDept" `
                    -Description "Groupe des responsables de $SubDept" `
                    -Path $DomainDN -Confirm:$false
                Write-Host "Groupe global managers cree: $ManagerGroupName"
            } catch {
                Write-Host "ERREUR creation $ManagerGroupName - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

# --- [6] REMPLIR LES GROUPES GLOBAUX AVEC LES UTILISATEURS ---
Write-Host "`n[6/11] Remplissage des groupes globaux avec utilisateurs..." -ForegroundColor Yellow

function Remove-Accents {
    param([string]$InputString)
    $Result = $InputString
    $Result = $Result.Replace('À', 'A').Replace('Á', 'A').Replace('Â', 'A').Replace('Ã', 'A').Replace('Ä', 'A').Replace('Å', 'A')
    $Result = $Result.Replace('È', 'E').Replace('É', 'E').Replace('Ê', 'E').Replace('Ë', 'E')
    $Result = $Result.Replace('Ì', 'I').Replace('Í', 'I').Replace('Î', 'I').Replace('Ï', 'I')
    $Result = $Result.Replace('Ñ', 'N')
    $Result = $Result.Replace('Ò', 'O').Replace('Ó', 'O').Replace('Ô', 'O').Replace('Õ', 'O').Replace('Ö', 'O')
    $Result = $Result.Replace('Ù', 'U').Replace('Ú', 'U').Replace('Û', 'U').Replace('Ü', 'U')
    $Result = $Result.Replace('Ç', 'C').Replace('Ý', 'Y').Replace('Æ', 'AE').Replace('Œ', 'OE')
    $Result = $Result.Replace('à', 'a').Replace('á', 'a').Replace('â', 'a').Replace('ã', 'a').Replace('ä', 'a').Replace('å', 'a')
    $Result = $Result.Replace('è', 'e').Replace('é', 'e').Replace('ê', 'e').Replace('ë', 'e')
    $Result = $Result.Replace('ì', 'i').Replace('í', 'i').Replace('î', 'i').Replace('ï', 'i')
    $Result = $Result.Replace('ñ', 'n')
    $Result = $Result.Replace('ò', 'o').Replace('ó', 'o').Replace('ô', 'o').Replace('õ', 'o').Replace('ö', 'o')
    $Result = $Result.Replace('ù', 'u').Replace('ú', 'u').Replace('û', 'u').Replace('ü', 'u')
    $Result = $Result.Replace('ç', 'c').Replace('ý', 'y').Replace('ß', 'ss').Replace('æ', 'ae').Replace('œ', 'oe')
    $Result = $Result -replace '\s+', ''
    $Result = $Result -replace '[^a-zA-Z0-9._-]', ''
    return $Result
}

foreach ($User in $Users) {
    $Prenom = $User.Prenom.Trim()
    $Nom = $User.Nom.Trim()
    $Dept = $User.Departement.Trim()
    
    $BaseName = (Remove-Accents -InputString "$Prenom.$Nom").ToLower()
    
    if ($BaseName.Length -gt 20) {
        $BaseName = $BaseName.Substring(0, 20)
    }
    
    $SamName = $BaseName
    $AdUser = Get-ADUser -Filter "SamAccountName -eq '$SamName'" -ErrorAction SilentlyContinue
    
    if ($AdUser) {
        if ($Dept.Contains("/")) {
            $Parts = $Dept.Split("/")
            $SubDept = $Parts[0].Trim()
            $Category = $Parts[1].Trim()
        } else {
            $SubDept = $Dept
            $Category = $null
        }
        
        $GGName = "GG_$SubDept"
        $GG = Get-ADGroup -Filter "SamAccountName -eq '$GGName'" -ErrorAction SilentlyContinue
        
        if ($GG) {
            $IsMember = Get-ADGroupMember -Identity $GG -ErrorAction SilentlyContinue | Where-Object { $_.SamAccountName -eq $SamName }
            if (-not $IsMember) {
                try {
                    Add-ADGroupMember -Identity $GG -Members $AdUser -Confirm:$false
                    Write-Host "User ajoute a $GGName : $SamName" -ForegroundColor Green
                } catch {
                    Write-Host "ERREUR ajout $SamName a $GGName : $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
}

Write-Host "`nAjout des responsables aux GG_Managers..." -ForegroundColor Cyan
foreach ($Category in $Structure.Keys) {
    foreach ($SubDept in $Structure[$Category].Keys) {
        $ManagerSamName = $ValidManagers["$Category|$SubDept"]
        
        if ($ManagerSamName) {
            $ManagerUser = Get-ADUser -Filter "SamAccountName -eq '$ManagerSamName'" -ErrorAction SilentlyContinue
            
            if ($ManagerUser) {
                $ManagerGroupName = "GG_Managers_$SubDept"
                $ManagerGroup = Get-ADGroup -Filter "SamAccountName -eq '$ManagerGroupName'" -ErrorAction SilentlyContinue
                
                if ($ManagerGroup) {
                    try {
                        Add-ADGroupMember -Identity $ManagerGroup -Members $ManagerUser -Confirm:$false -ErrorAction SilentlyContinue
                        Write-Host "Manager ajoute a $ManagerGroupName : $ManagerSamName" -ForegroundColor Green
                    } catch {
                        # Silencieux
                    }
                }
            }
        }
    }
}

Write-Host "`nAjout de GG_Direction a DL_Commun_RW..." -ForegroundColor Cyan
$GGDir = Get-ADGroup -Filter "SamAccountName -eq 'GG_Direction'" -ErrorAction SilentlyContinue
$DLComRW = Get-ADGroup -Filter "SamAccountName -eq 'DL_Commun_RW'" -ErrorAction SilentlyContinue

if ($GGDir -and $DLComRW) {
    try {
        Add-ADGroupMember -Identity $DLComRW -Members $GGDir -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "GG_Direction ajoute a DL_Commun_RW" -ForegroundColor Green
    } catch {
        Write-Host "GG_Direction deja dans DL_Commun_RW" -ForegroundColor Gray
    }
}

# --- [7] CREER LE PARTAGE AUTOMATIQUE (SMB SHARE) ---
Write-Host "`n[7/11] Creation du partage SMB automatique..." -ForegroundColor Yellow

$ShareName = "Share"
$ShareExisting = Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue

if (-not $ShareExisting) {
    try {
        New-SmbShare -Name $ShareName -Path $RootPath `
            -ChangeAccess "Everyone" `
            -Description "Partage fichiers departements - Acces reseau via EVERYONE" `
            -Confirm:$false
        Write-Host "Partage SMB cree: \\$ComputerName\$ShareName -> $RootPath" -ForegroundColor Green
        Write-Host "  Acces SMB: Change + Read pour Everyone" -ForegroundColor Green
    } catch {
        Write-Host "ERREUR creation partage SMB: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Partage SMB existe deja: \\$ComputerName\$ShareName" -ForegroundColor Gray
}

# --- [8a] PERMISSIONS NTFS - DOSSIERS PARENTS ---
Write-Host "`n[8a/11] Permissions sur dossiers PARENTS (v17 FIX)..." -ForegroundColor Magenta

function Set-ParentPermissions {
    param([string]$Path, [hashtable]$SubDepts)
    
    $PathExists = Test-Path -Path $Path -ErrorAction SilentlyContinue
    if (-not $PathExists) { return }
    
    try {
        $Acl = Get-Acl -Path $Path -ErrorAction Stop
        if ($null -eq $Acl) { return }
        
        $Acl.SetAccessRuleProtection($true, $false)
        
        # Nettoyer mais GARDER Administrator/SYSTEM
        $AclToKeep = @()
        foreach ($AccessRule in $Acl.Access) {
            if ($AccessRule.IdentityReference.Value -like "*SYSTEM*" -or `
                $AccessRule.IdentityReference.Value -like "*Administrateurs*" -or `
                $AccessRule.IdentityReference.Value -like "*Administrators*" -or `
                $AccessRule.IdentityReference.Value -like "*CREATOR OWNER*") {
                $AclToKeep += $AccessRule
            }
        }
        
        $NewAcl = New-Object System.Security.AccessControl.DirectorySecurity
        $NewAcl.SetAccessRuleProtection($true, $false)
        
        foreach ($Rule in $AclToKeep) { $NewAcl.AddAccessRule($Rule) }
        
        # FORCE ADMIN FULL CONTROL EXPLICIT
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "Administrators",
            "FullControl",
            "ContainerInherit, ObjectInherit",
            "None",
            "Allow"
        )
        $NewAcl.AddAccessRule($AccessRule)

        foreach ($SubDept in $SubDepts.Keys) {
            $DLRead = "DL_$($SubDept)_R"
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                "$Domain\$DLRead", "ReadAndExecute", "None", "None", "Allow"
            )
            $NewAcl.AddAccessRule($AccessRule)
        }
        
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "$Domain\GG_Direction", "Modify", "None", "None", "Allow"
        )
        $NewAcl.AddAccessRule($AccessRule)
        
        Set-Acl -Path $Path -AclObject $NewAcl
        Write-Host "  ✅ Permissions appliquees sur parent: $(Split-Path -Leaf $Path)" -ForegroundColor Green
        
    } catch {
        Write-Host "  ❌ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

foreach ($Category in $Structure.Keys) {
    $CategoryPath = Join-Path $RootPath $Category
    Write-Host "  Parent: $($Category)" -ForegroundColor Cyan
    Set-ParentPermissions -Path $CategoryPath -SubDepts $Structure[$Category]
}

# --- [8b/11] PERMISSIONS NTFS - DOSSIER COMMUN ---
Write-Host "`n[8b/11] Permissions sur dossier COMMUN..." -ForegroundColor Yellow

if ((Test-Path $CommonPath -ErrorAction SilentlyContinue)) {
    try {
        $Acl = Get-Acl $CommonPath -ErrorAction Stop
        if ($Acl) {
            $Acl.SetAccessRuleProtection($true, $false)
            
            $AclToKeep = @()
            foreach ($AccessRule in $Acl.Access) {
                if ($AccessRule.IdentityReference.Value -like "*SYSTEM*" -or `
                    $AccessRule.IdentityReference.Value -like "*Administrateurs*" -or `
                    $AccessRule.IdentityReference.Value -like "*Administrators*" -or `
                    $AccessRule.IdentityReference.Value -like "*CREATOR OWNER*") {
                    $AclToKeep += $AccessRule
                }
            }
            
            $NewAcl = New-Object System.Security.AccessControl.DirectorySecurity
            $NewAcl.SetAccessRuleProtection($true, $false)
            foreach ($Rule in $AclToKeep) { $NewAcl.AddAccessRule($Rule) }
            
            # FORCE ADMIN
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                "Administrators", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow"
            )
            $NewAcl.AddAccessRule($AccessRule)
            
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                "$Domain\DL_Commun_R", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow"
            )
            $NewAcl.AddAccessRule($AccessRule)
            
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                "$Domain\DL_Commun_RW", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow"
            )
            $NewAcl.AddAccessRule($AccessRule)
            
            Set-Acl -Path $CommonPath -AclObject $NewAcl
            Write-Host "  ✅ Commun - Permissions appliquees" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ❌ ERREUR Commun: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- [8c/11] PERMISSIONS NTFS - DOSSIERS ENFANTS ---
Write-Host "`n[8c/11] Permissions sur dossiers ENFANTS (v17 FIX)..." -ForegroundColor Magenta

function Set-ChildPermissions {
    param([string]$Path, [string]$SubDept)
    
    $PathExists = Test-Path -Path $Path -ErrorAction SilentlyContinue
    if (-not $PathExists) { return }
    
    try {
        $Acl = Get-Acl -Path $Path -ErrorAction Stop
        if ($null -eq $Acl) { return }
        
        $Acl.SetAccessRuleProtection($true, $false)
        
        $AclToKeep = @()
        foreach ($AccessRule in $Acl.Access) {
            if ($AccessRule.IdentityReference.Value -like "*SYSTEM*" -or `
                $AccessRule.IdentityReference.Value -like "*Administrateurs*" -or `
                $AccessRule.IdentityReference.Value -like "*Administrators*" -or `
                $AccessRule.IdentityReference.Value -like "*CREATOR OWNER*") {
                $AclToKeep += $AccessRule
            }
        }
        
        $NewAcl = New-Object System.Security.AccessControl.DirectorySecurity
        $NewAcl.SetAccessRuleProtection($true, $false)
        foreach ($Rule in $AclToKeep) { $NewAcl.AddAccessRule($Rule) }
        
        # FORCE ADMIN FULL CONTROL
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "Administrators", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow"
        )
        $NewAcl.AddAccessRule($AccessRule)
        
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "$Domain\DL_$($SubDept)_R", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow"
        )
        $NewAcl.AddAccessRule($AccessRule)
        
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "$Domain\DL_$($SubDept)_RW", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow"
        )
        $NewAcl.AddAccessRule($AccessRule)
        
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "$Domain\GG_Direction", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow"
        )
        $NewAcl.AddAccessRule($AccessRule)
        
        Set-Acl -Path $Path -AclObject $NewAcl
        Write-Host "    ✅ $($SubDept)" -ForegroundColor Green
        
    } catch {
        Write-Host "    ❌ ERREUR $($SubDept): $($_.Exception.Message)" -ForegroundColor Red
    }
}

foreach ($Category in $Structure.Keys) {
    $CategoryPath = Join-Path $RootPath $Category
    Write-Host "  Enfants de $($Category)..." -ForegroundColor Cyan
    
    foreach ($SubDept in $Structure[$Category].Keys) {
        $SubPath = Join-Path $CategoryPath $SubDept
        Set-ChildPermissions -Path $SubPath -SubDept $SubDept
    }
}

# --- [9] REMPLIR LES DL - CROSS-DEPARTMENT PERMISSIONS ---
Write-Host "`n[9/11] Remplissage des groupes locaux (DL) - CROSS-DEPARTMENT..." -ForegroundColor Yellow

foreach ($Category in $Structure.Keys) {
    foreach ($SubDept in $Structure[$Category].Keys) {
        $GGName = "GG_$SubDept"
        $DLNameRW = "DL_$($SubDept)_RW"
        
        $GG = Get-ADGroup -Filter "SamAccountName -eq '$GGName'" -ErrorAction SilentlyContinue
        $DLRW = Get-ADGroup -Filter "SamAccountName -eq '$DLNameRW'" -ErrorAction SilentlyContinue
        
        if ($GG -and $DLRW) {
            try {
                Add-ADGroupMember -Identity $DLRW -Members $GG -Confirm:$false -ErrorAction SilentlyContinue
                Write-Host "GG $GGName ajoute a DL_$($SubDept)_RW ✅ (ECRITURE)" -ForegroundColor Green
            } catch { }
        }
        
        foreach ($OtherSubDept in $Structure[$Category].Keys) {
            if ($OtherSubDept -ne $SubDept) {
                $DLNameOtherR = "DL_$($OtherSubDept)_R"
                $DLOtherR = Get-ADGroup -Filter "SamAccountName -eq '$DLNameOtherR'" -ErrorAction SilentlyContinue
                
                if ($GG -and $DLOtherR) {
                    try {
                        Add-ADGroupMember -Identity $DLOtherR -Members $GG -Confirm:$false -ErrorAction SilentlyContinue
                        Write-Host "GG $GGName ajoute a DL_$($OtherSubDept)_R ✅" -ForegroundColor Green
                    } catch { }
                }
            }
        }
        
        $ManagerGroupName = "GG_Managers_$SubDept"
        $ManagerGroup = Get-ADGroup -Filter "SamAccountName -eq '$ManagerGroupName'" -ErrorAction SilentlyContinue
        
        if ($ManagerGroup -and $DLRW) {
            try {
                Add-ADGroupMember -Identity $DLRW -Members $ManagerGroup -Confirm:$false -ErrorAction SilentlyContinue
                Write-Host "$ManagerGroupName ajoute a DL_$($SubDept)_RW ✅" -ForegroundColor Green
            } catch { }
        }
        
        foreach ($OtherSubDept in $Structure[$Category].Keys) {
            if ($OtherSubDept -ne $SubDept) {
                $DLNameOtherRW = "DL_$($OtherSubDept)_RW"
                $DLOtherRW = Get-ADGroup -Filter "SamAccountName -eq '$DLNameOtherRW'" -ErrorAction SilentlyContinue
                
                if ($ManagerGroup -and $DLOtherRW) {
                    try {
                        Add-ADGroupMember -Identity $DLOtherRW -Members $ManagerGroup -Confirm:$false -ErrorAction SilentlyContinue
                        Write-Host "$ManagerGroupName ajoute a DL_$($OtherSubDept)_RW ✅" -ForegroundColor Green
                    } catch { }
                }
            }
        }
    }
}

Write-Host "`nAjout de TOUS les GG a DL_Commun_R..." -ForegroundColor Cyan
$DLComR = Get-ADGroup -Filter "SamAccountName -eq 'DL_Commun_R'" -ErrorAction SilentlyContinue

if ($DLComR) {
    foreach ($Category in $Structure.Keys) {
        foreach ($SubDept in $Structure[$Category].Keys) {
            $GGName = "GG_$SubDept"
            $GG = Get-ADGroup -Filter "SamAccountName -eq '$GGName'" -ErrorAction SilentlyContinue
            
            if ($GG) {
                try {
                    Add-ADGroupMember -Identity $DLComR -Members $GG -Confirm:$false -ErrorAction SilentlyContinue
                    Write-Host "GG $GGName ajoute a DL_Commun_R ✅" -ForegroundColor Green
                } catch { }
            }
        }
    }
}

Write-Host "`nAjout de TOUS les GG_Managers a DL_Commun_RW..." -ForegroundColor Cyan
$DLComRW = Get-ADGroup -Filter "SamAccountName -eq 'DL_Commun_RW'" -ErrorAction SilentlyContinue

if ($DLComRW) {
    foreach ($Category in $Structure.Keys) {
        foreach ($SubDept in $Structure[$Category].Keys) {
            $ManagerGroupName = "GG_Managers_$SubDept"
            $ManagerGroup = Get-ADGroup -Filter "SamAccountName -eq '$ManagerGroupName'" -ErrorAction SilentlyContinue
            
            if ($ManagerGroup) {
                try {
                    Add-ADGroupMember -Identity $DLComRW -Members $ManagerGroup -Confirm:$false -ErrorAction SilentlyContinue
                    Write-Host "$ManagerGroupName ajoute a DL_Commun_RW ✅" -ForegroundColor Green
                } catch { }
            }
        }
    }
}

# --- [10] VERIFICATION FINALE ---
Write-Host "`n[10/11] Verification finale des permissions..." -ForegroundColor Yellow

foreach ($Category in $Structure.Keys) {
    $CategoryPath = Join-Path $RootPath $Category
    if ((Test-Path $CategoryPath -ErrorAction SilentlyContinue)) {
        $Acl = Get-Acl $CategoryPath -ErrorAction SilentlyContinue
        if ($Acl) {
            Write-Host "`n$Category - Permissions actuelles:" -ForegroundColor Cyan
            $Acl.Access | Where-Object { $_.IdentityReference -notlike "*SYSTEM*" -and $_.IdentityReference -notlike "*Administrateurs*" -and $_.IdentityReference -notlike "*Administrators*" -and $_.IdentityReference -notlike "*CREATOR OWNER*" } | ForEach-Object {
                Write-Host "  ✅ $($_.IdentityReference) - $($_.FileSystemRights) - Inheritance: $($_.InheritanceFlags)" -ForegroundColor Green
            }
        }
    }
}

# --- [11] VERIFICATION PSO APPLIQUEE ---
Write-Host "`n[11/11] Verification finale PSO Direction...`n" -ForegroundColor Yellow

$GGDir = Get-ADGroup -Filter "SamAccountName -eq 'GG_Direction'" -ErrorAction SilentlyContinue

if ($GGDir) {
    $PSO = Get-ADFineGrainedPasswordPolicy -Identity "PSO_Direction_15chars"
    $PSO | Select-Object Name, MinPasswordLength, ComplexityEnabled, MaxPasswordAge, Precedence

} else {
    Write-Host "⚠️  Groupe GG_Direction non trouve" -ForegroundColor Yellow
}

Write-Host "CONFIGURATION COMPLETE - AVEC PSO DIRECTION" -ForegroundColor Green

