Write-Host "Activation de la Corbeille AD pour la foret Belgique.lan..." -ForegroundColor Yellow

try {
    Enable-ADOptionalFeature `
        -Identity "Recycle Bin Feature" `
        -Scope ForestOrConfigurationSet `
        -Target "Belgique.lan" `
        -Confirm:$false

    Write-Host "OK: Corbeille AD activee." -ForegroundColor Green
} catch {
    Write-Host "ERREUR activation Corbeille AD: $_" -ForegroundColor Red
}

$CSVPath = "$env:USERPROFILE\Documents\Employes-Liste6_ADAPTEE.csv"

Write-Host "IMPORT UTILISATEURS + CONFIG AD COMPLET" -ForegroundColor Cyan
Write-Host "Domaine: Belgique.lan" -ForegroundColor Cyan

if (-not (Test-Path $CSVPath)) {
    Write-Host "ERREUR: Fichier CSV non trouve!" -ForegroundColor Red
    Break
}


function Remove-Accents {
    param(
        [string]$InputString
    )
    
    $Result = $InputString
    
    # Remplacer les accents majuscules
    $Result = $Result.Replace('À', 'A')
    $Result = $Result.Replace('Á', 'A')
    $Result = $Result.Replace('Â', 'A')
    $Result = $Result.Replace('Ã', 'A')
    $Result = $Result.Replace('Ä', 'A')
    $Result = $Result.Replace('Å', 'A')
    $Result = $Result.Replace('È', 'E')
    $Result = $Result.Replace('É', 'E')
    $Result = $Result.Replace('Ê', 'E')
    $Result = $Result.Replace('Ë', 'E')
    $Result = $Result.Replace('Ì', 'I')
    $Result = $Result.Replace('Í', 'I')
    $Result = $Result.Replace('Î', 'I')
    $Result = $Result.Replace('Ï', 'I')
    $Result = $Result.Replace('Ñ', 'N')
    $Result = $Result.Replace('Ò', 'O')
    $Result = $Result.Replace('Ó', 'O')
    $Result = $Result.Replace('Ô', 'O')
    $Result = $Result.Replace('Õ', 'O')
    $Result = $Result.Replace('Ö', 'O')
    $Result = $Result.Replace('Ù', 'U')
    $Result = $Result.Replace('Ú', 'U')
    $Result = $Result.Replace('Û', 'U')
    $Result = $Result.Replace('Ü', 'U')
    $Result = $Result.Replace('Ç', 'C')
    $Result = $Result.Replace('Ý', 'Y')
    $Result = $Result.Replace('Æ', 'AE')
    $Result = $Result.Replace('Œ', 'OE')
    
    # Remplacer les accents minuscules
    $Result = $Result.Replace('à', 'a')
    $Result = $Result.Replace('á', 'a')
    $Result = $Result.Replace('â', 'a')
    $Result = $Result.Replace('ã', 'a')
    $Result = $Result.Replace('ä', 'a')
    $Result = $Result.Replace('å', 'a')
    $Result = $Result.Replace('è', 'e')
    $Result = $Result.Replace('é', 'e')
    $Result = $Result.Replace('ê', 'e')
    $Result = $Result.Replace('ë', 'e')
    $Result = $Result.Replace('ì', 'i')
    $Result = $Result.Replace('í', 'i')
    $Result = $Result.Replace('î', 'i')
    $Result = $Result.Replace('ï', 'i')
    $Result = $Result.Replace('ñ', 'n')
    $Result = $Result.Replace('ò', 'o')
    $Result = $Result.Replace('ó', 'o')
    $Result = $Result.Replace('ô', 'o')
    $Result = $Result.Replace('õ', 'o')
    $Result = $Result.Replace('ö', 'o')
    $Result = $Result.Replace('ù', 'u')
    $Result = $Result.Replace('ú', 'u')
    $Result = $Result.Replace('û', 'u')
    $Result = $Result.Replace('ü', 'u')
    $Result = $Result.Replace('ç', 'c')
    $Result = $Result.Replace('ý', 'y')
    $Result = $Result.Replace('ß', 'ss')
    $Result = $Result.Replace('æ', 'ae')
    $Result = $Result.Replace('œ', 'oe')
    
    # Supprimer les espaces et caractères spéciaux
    $Result = $Result -replace '\s+', ''
    $Result = $Result -replace '[^a-zA-Z0-9._-]', ''
    
    return $Result
}

# --- [1] Lecture CSV ---
Write-Host "`n[1/7] Lecture du CSV..." -ForegroundColor Yellow
$Users = Import-Csv -Path $CSVPath -Delimiter ";" -Encoding UTF8
Write-Host "OK: $($Users.Count) utilisateurs a importer" -ForegroundColor Green

# --- [2] Analyse Structure OUs ---
Write-Host "`n[2/7] Analyse et Creation de la structure OUs..." -ForegroundColor Yellow

$OUStructure = @{}
$SingleOUs = @()

foreach ($User in $Users) {
    $Dept = $User.Departement.Trim()
    if ($Dept) {
        if ($Dept.Contains("/")) {
            $Parts = $Dept.Split("/")
            $SubDept = $Parts[0].Trim()
            $Category = $Parts[1].Trim()
            
            if (-not $OUStructure.ContainsKey($Category)) {
                $OUStructure[$Category] = @()
            }
            if ($OUStructure[$Category] -notcontains $SubDept) {
                $OUStructure[$Category] += $SubDept
            }
        } else {
            if ($SingleOUs -notcontains $Dept) {
                $SingleOUs += $Dept
            }
        }
    }
}

# 2a. Création OUs SIMPLES
foreach ($OUName in $SingleOUs) {
    $OUPath = "OU=${OUName},DC=Belgique,DC=lan"
    try {
        if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '${OUName}'" -SearchBase "DC=Belgique,DC=lan" -SearchScope OneLevel -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $OUName -Path "DC=Belgique,DC=lan" -Confirm:$false
            Write-Host "OK: OU simple creee: ${OUName}" -ForegroundColor Green
            Set-ADOrganizationalUnit -Identity $OUPath -ProtectedFromAccidentalDeletion $true -Confirm:$false
        } else {
            Write-Host "OK: OU simple existe: ${OUName}" -ForegroundColor Gray
        }
    } catch { 
        Write-Host "ERREUR OU ${OUName}: $_" -ForegroundColor Red 
    }
}

# 2b. Création OUs HIERARCHIQUES
foreach ($Category in $OUStructure.Keys) {
    $CategoryOUPath = "OU=${Category},DC=Belgique,DC=lan"
    try {
        if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '${Category}'" -SearchBase "DC=Belgique,DC=lan" -SearchScope OneLevel -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $Category -Path "DC=Belgique,DC=lan" -Confirm:$false
            Write-Host "OK: OU categorie creee: ${Category}" -ForegroundColor Green
            Set-ADOrganizationalUnit -Identity $CategoryOUPath -ProtectedFromAccidentalDeletion $true -Confirm:$false
        }
    } catch { 
        Write-Host "ERREUR OU ${Category}: $_" -ForegroundColor Red 
    }
    
    foreach ($SubDept in $OUStructure[$Category]) {
        $SubOUPath = "OU=${SubDept},OU=${Category},DC=Belgique,DC=lan"
        try {
            if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '${SubDept}'" -SearchBase $CategoryOUPath -ErrorAction SilentlyContinue)) {
                New-ADOrganizationalUnit -Name $SubDept -Path $CategoryOUPath -Confirm:$false
                Write-Host "  OK: OU sous-dept creee: ${Category} > ${SubDept}" -ForegroundColor Green
                Set-ADOrganizationalUnit -Identity $SubOUPath -ProtectedFromAccidentalDeletion $true -Confirm:$false
            }
        } catch { 
            Write-Host "  ERREUR OU ${SubDept}: $_" -ForegroundColor Red 
        }
    }
}

# 2c. Création OU Ordinateurs
Write-Host "`nCreation OU Ordinateurs..." -ForegroundColor Yellow
$ComputersOUPath = "OU=Ordinateurs,DC=Belgique,DC=lan"
try {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Ordinateurs'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name "Ordinateurs" -Path "DC=Belgique,DC=lan" -Confirm:$false
        Write-Host "OK: OU Ordinateurs creee" -ForegroundColor Green
    }
} catch { Write-Host "ERREUR OU Ordinateurs: $_" -ForegroundColor Red }

# --- [3] Fonction generation mots de passe securises ---
Write-Host "`n[3/7] Generation mots de passe aleatoires (20 chars)..." -ForegroundColor Yellow

function Generate-SecurePassword {
    $Length = 20
    $Chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$%^&*"
    $SecureRandom = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $RandomBytes = New-Object byte[] $Length
    $SecureRandom.GetBytes($RandomBytes)
    $Password = ""
    foreach ($Byte in $RandomBytes) {
        $Password += $Chars[$Byte % $Chars.Length]
    }
    $Password = "A1!@" + $Password.Substring(0, 16)
    return $Password
}

# --- [4] Creation Users avec mots de passe aleatoires ---
Write-Host "`n[4/7] Creation des utilisateurs..." -ForegroundColor Yellow

$UserCount = 0
$ErrorCount = 0
$UsedAccounts = @{}
$PasswordLog = @()

foreach ($User in $Users) {
    $Prenom = $User.Prenom.Trim()
    $Nom = $User.Nom.Trim()
    $Departement = $User.Departement.Trim()
    $Bureau = $User.Bureau.Trim()
    $Fonction = if ($User.PSObject.Properties.Name -contains 'Fonction') { $User.Fonction.Trim() } else { $User.Description.Trim() }
    
    # NORMALISATION DES ACCENTS - FORMAT PRENOM.NOM
    $BaseName = (Remove-Accents -InputString "$Prenom.$Nom").ToLower()
    
    if ($BaseName.Length -gt 20) { 
        $BaseName = $BaseName.Substring(0, 20) 
    }
    
    # Gérer les doublons avec suffixe
    $SamName = $BaseName
    $Suffix = 0
    while ($UsedAccounts.ContainsKey($SamName) -or (Get-ADUser -Filter "SamAccountName -eq '${SamName}'" -ErrorAction SilentlyContinue)) {
        $Suffix++
        $SamName = "$BaseName$Suffix"
    }
    $UsedAccounts[$SamName] = $true

    # Détermination du chemin OU
    if ($Departement.Contains("/")) {
        $Parts = $Departement.Split("/")
        $SubDept = $Parts[0].Trim()
        $Category = $Parts[1].Trim()
        $OUPath = "OU=${SubDept},OU=${Category},DC=Belgique,DC=lan"
    } else {
        $OUPath = "OU=${Departement},DC=Belgique,DC=lan"
    }

    # Génération mot de passe ALEATOIRE
    $NewPassword = Generate-SecurePassword
    $SecurePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force

    # Création utilisateur AD - SANS ChangePasswordAtLogon
    try {
        $UserParams = @{
            SamAccountName = $SamName
            UserPrincipalName = "$SamName@belgique.lan"
            GivenName = $Prenom
            Surname = $Nom
            DisplayName = "$Prenom $Nom"
            Name = "$Prenom $Nom"
            AccountPassword = $SecurePassword
            Enabled = $true
            Path = $OUPath
            ChangePasswordAtLogon = $false
            Confirm = $false
        }
        
        if ($Fonction) {
            $UserParams.Description = $Fonction
        }
        
        if ($Bureau) {
            $UserParams.Office = $Bureau
        }

        New-ADUser @UserParams
        Write-Host "OK: User cree: $SamName (OU: $OUPath)" -ForegroundColor Green
        
        $PasswordLog += [PSCustomObject]@{
            SamAccountName = $SamName
            DisplayName = "$Prenom $Nom"
            Password = $NewPassword
            CreatedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        $UserCount++
    } catch {
        Write-Host "ERREUR creation user $SamName : $_" -ForegroundColor Red
        $ErrorCount++
    }
}

Write-Host "Utilisateurs crees: $UserCount | Erreurs: $ErrorCount" -ForegroundColor Cyan

# --- [5] Delegation des OUs et ACL ---
Write-Host "`n[5/7] Configuration delegation administrative..." -ForegroundColor Yellow

$DelegationMap = @{
    "Commerciaux" = "yan.kowal"
    "Technique" = "axel.irakoze"
    "Informatique" = "adrien.ilic"
    "Ressources humaines" = "romain.marcel"
    "Direction" = "pol.kuntonda-luezi"
    "R&D" = "antoine.brard"
    "Marketting" = "maxime.gudin"
    "Finances" = "benjamin.tollet"
}

$DelegCount = 0
$PermCount = 0
$PermFail = 0

foreach ($Dept in $DelegationMap.Keys) {
    $ManagerID = $DelegationMap[$Dept]
    $OUPath = "OU=${Dept},DC=Belgique,DC=lan"
    
    $Manager = Get-ADUser -Filter "SamAccountName -eq '${ManagerID}'" -Properties DisplayName, Title, SID -ErrorAction SilentlyContinue
    
    if ($Manager) {
        Write-Host "Delegation $Dept ->" -NoNewline
        Write-Host " $($Manager.DisplayName) ($ManagerID)" -ForegroundColor Green
        $DelegCount++
        
        # Appliquer les permissions ACL
        try {
            $OU = Get-ADOrganizationalUnit -Filter "distinguishedName -eq '${OUPath}'" -ErrorAction SilentlyContinue
            
            if ($OU) {
                $ACL = Get-Acl -Path "AD:\$($OU.DistinguishedName)"
                $UserSID = $Manager.SID
                
                # Permission 1: Reset Password (GUID: 00299570-246d-11d0-a768-00aa006e0529)
                $ResetPasswordGUID = [GUID]"00299570-246d-11d0-a768-00aa006e0529"
                $ACE_Reset = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
                    $UserSID,
                    [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight,
                    [System.Security.AccessControl.AccessControlType]::Allow,
                    $ResetPasswordGUID,
                    [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All
                )
                
                # Permission 2: Modify All Properties
                $ACE_Write = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
                    $UserSID,
                    [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty,
                    [System.Security.AccessControl.AccessControlType]::Allow,
                    [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All
                )
                
                $ACL.AddAccessRule($ACE_Reset)
                $ACL.AddAccessRule($ACE_Write)
                
                Set-Acl -Path "AD:\$($OU.DistinguishedName)" -AclObject $ACL
                
                Write-Host "  ✓ ACL appliquee: ${ManagerID} -> ${Dept}" -ForegroundColor Green
                $PermCount++
            }
        } catch {
            Write-Host "  ✗ ERREUR ACL ${ManagerID}: $_" -ForegroundColor Red
            $PermFail++
        }
    } else {
        Write-Host "Delegation $Dept ->" -NoNewline
        Write-Host " ERREUR (User introuvable)" -ForegroundColor Red
        $PermFail++
    }
}

# --- [6] Application des horaires (Logon Hours) ---
Write-Host "`n[6/7] Application des horaires de connexion..." -ForegroundColor Yellow

$StdApplied = 0
$ITApplied = 0
$HoursFailed = 0

$ITDepts = @("HotLine", "Systemes", "Developpement", "Systèmes", "Développement")

$AllUsers = Get-ADUser -Filter "Enabled -eq `$true" -SearchBase "DC=Belgique,DC=lan" -Properties DistinguishedName | `
    Where-Object { $_.SamAccountName -notmatch "^(Administrator|Guest|krbtgt)" }

foreach ($User in $AllUsers) {
    $SamName = $User.SamAccountName
    $DN = $User.DistinguishedName
    $IsIT = $false
    
    if ($DN -match "OU=([^,]+),OU=") {
        $SubDept = $Matches[1]
        if ($ITDepts -contains $SubDept) { $IsIT = $true }
    }

    if ($IsIT) {
        $Cmd = "net user $SamName /times:all"
        Invoke-Expression $Cmd 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { 
            Write-Host "OK: $SamName -> IT (24h)" -ForegroundColor Cyan
            $ITApplied++ 
        } else { $HoursFailed++ }
    } else {
        $Cmd = "net user $SamName /times:M-F,6am-6pm"
        Invoke-Expression $Cmd 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { 
            Write-Host "OK: $SamName -> STD (M-F 6-18h)" -ForegroundColor Green
            $StdApplied++ 
        } else { $HoursFailed++ }
    }
}

# --- [7] Export des mots de passe ---
Write-Host "`n[7/7] Export des mots de passe..." -ForegroundColor Yellow

$OutputPath = "$env:USERPROFILE\Desktop\Passwords_Export_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').csv"
$PasswordLog | Export-Csv -Path $OutputPath -Delimiter ";" -Encoding UTF8 -NoTypeInformation
Write-Host "OK: Mots de passe exportes: $OutputPath" -ForegroundColor Green

Write-Host "CONFIGURATION TERMINEE" -ForegroundColor Green
Write-Host "`nResume:" -ForegroundColor Cyan
Write-Host "- OUs creees: $($OUStructure.Count) categories + $($SingleOUs.Count) simples" -ForegroundColor Green
Write-Host "- Utilisateurs crees: $UserCount" -ForegroundColor Green
Write-Host "- Erreurs users: $ErrorCount" -ForegroundColor Yellow
Write-Host "- Delegations configurees: $DelegCount" -ForegroundColor Green
Write-Host "- Permissions ACL appliquees: $PermCount" -ForegroundColor Green
Write-Host "- Erreurs ACL: $PermFail" -ForegroundColor Yellow
Write-Host "- Horaires appliques (STD): $StdApplied" -ForegroundColor Green
Write-Host "- Horaires appliques (IT): $ITApplied" -ForegroundColor Cyan
Write-Host "- Erreurs horaires: $HoursFailed" -ForegroundColor Yellow
Write-Host "- Mots de passe: $OutputPath" -ForegroundColor Green
Write-Host "`n⚠️  IMPORTANT:" -ForegroundColor Yellow
Write-Host "  ✓ ChangePasswordAtLogon = FALSE (pas de changement force)" -ForegroundColor Green
Write-Host "  ✓ Delegations ACL appliquees par departement" -ForegroundColor Green
Write-Host "  ✓ Logon Hours configurees (IT 24h / STD M-F 6-18h)" -ForegroundColor Green
Write-Host "  ✓ Normalisation des accents activee" -ForegroundColor Green
Write-Host "  ⚠  Mots de passe: A DISTRIBUER par mail chiffre UNIQUEMENT" -ForegroundColor Red
Write-Host "  ⚠  A SUPPRIMER apres distribution" -ForegroundColor Red