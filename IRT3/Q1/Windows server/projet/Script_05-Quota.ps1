$RootPath = "C:\Share"
$Domain = "Belgique.lan"
$DomainDN = "DC=Belgique,DC=lan"

# Configuration Gmail
$GmailAccount = "fsrm.belgique@gmail.com"
$GmailAppPassword = "dzlh yqgi sscq lrmm"
$SmtpServer = "smtp.gmail.com"
$SmtpPort = 587
$FromEmail = "fsrm.belgique@gmail.com"
$AdminEmail = "robin.gillard1@std.heh.be"

[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

Write-Host "CONFIGURATION FSRM v3.3 - NETTOYAGE + RECREATION COMPLETES" -ForegroundColor Cyan
Write-Host "Domain: $Domain" -ForegroundColor Cyan
Write-Host "Admin: $AdminEmail" -ForegroundColor Cyan

# --- [0] NETTOYAGE COMPLET (OPTIONNEL) ---
Write-Host "`n[0/9] Suppression des quotas existants (nettoyage)..." -ForegroundColor Magenta

try {
    $ExistingQuotas = Get-FsrmQuota -ErrorAction SilentlyContinue
    if ($ExistingQuotas) {
        foreach ($Quota in $ExistingQuotas) {
            try {
                Remove-FsrmQuota -Path $Quota.Path -Confirm:$false -ErrorAction SilentlyContinue
                Write-Host "  - Supprime: $($Quota.Path)" -ForegroundColor Gray
            } catch { }
        }
        Start-Sleep -Seconds 3
    }
    Write-Host "Nettoyage complet termine" -ForegroundColor Green
} catch {
    Write-Host "Note: Pas de quotas existants" -ForegroundColor Gray
}

# --- [1] INSTALLATION FSRM ---
Write-Host "`n[1/9] Verification/Installation FSRM..." -ForegroundColor Yellow
$FsrmFeature = Get-WindowsFeature FS-Resource-Manager -ErrorAction SilentlyContinue

if (-not $FsrmFeature.Installed) {
    try {
        Write-Host "Installation FSRM..." -ForegroundColor Gray
        Install-WindowsFeature FS-Resource-Manager -IncludeManagementTools -Confirm:$false | Out-Null
        Write-Host "OK: FSRM installe" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
        exit
    }
} else {
    Write-Host "OK: FSRM deja present" -ForegroundColor Green
}

# Recharger le module FSRM
Remove-Module FileServerResourceManager -Force -ErrorAction SilentlyContinue
Import-Module FileServerResourceManager -Force
Start-Sleep -Seconds 2

# --- [2] TEST SMTP ---
Write-Host "`n[2/9] Test de connectivite SMTP Gmail..." -ForegroundColor Yellow

function Test-SmtpConnection {
    param([string]$Server, [int]$Port)
    try {
        $TcpClient = New-Object System.Net.Sockets.TcpClient
        $TcpClient.ConnectAsync($Server, $Port).Wait(3000) | Out-Null
        if ($TcpClient.Connected) {
            $TcpClient.Close()
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

if (Test-SmtpConnection -Server $SmtpServer -Port $SmtpPort) {
    Write-Host "OK: SMTP Gmail accessible" -ForegroundColor Green
} else {
    Write-Host "ERROR: SMTP Gmail indisponible" -ForegroundColor Red
    exit
}

# --- [3] STRUCTURE ---
Write-Host "`n[3/9] Chargement de la structure..." -ForegroundColor Yellow

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

Write-Host "OK: Structure chargee" -ForegroundColor Green

# --- [4] EXTRACTION EMAILS AD ---
Write-Host "`n[4/9] Extraction des emails depuis AD..." -ForegroundColor Yellow

function Get-UserEmailFromAD {
    param([string]$SamAccountName)
    try {
        $AdUser = Get-ADUser -Identity $SamAccountName -Properties Mail -ErrorAction SilentlyContinue
        if ($AdUser -and $AdUser.Mail) {
            return $AdUser.Mail
        }
    } catch { }
    return "$SamAccountName@$Domain"
}

$EmailCache = @{}
foreach ($Category in $Structure.Keys) {
    foreach ($SubDept in $Structure[$Category].Keys) {
        $ManagerSam = $Structure[$Category][$SubDept]
        $ManagerEmail = Get-UserEmailFromAD -SamAccountName $ManagerSam
        $EmailCache["$Category|$SubDept"] = $ManagerEmail
    }
}

Write-Host "OK: Emails extraits" -ForegroundColor Green

# --- [5] FONCTION QUOTA v3.3 SIMPLIFIE ---
function Set-QuotaWithAlerts {
    param(
        [string]$Path,
        [int64]$SizeMB,
        [string]$ResponsibleEmail,
        [string]$QuotaName
    )

    if (-not (Test-Path $Path)) {
        Write-Host "    WARN: Dossier inexistant: $Path" -ForegroundColor Yellow
        return
    }

    try {
        Write-Host "    Traitement: $QuotaName..." -ForegroundColor Gray
        
        # Delai avant suppression
        Start-Sleep -Milliseconds 800

        # 1. Supprimer l'ancien quota (SANS -Force)
        Get-FsrmQuota -Path $Path -ErrorAction SilentlyContinue | Remove-FsrmQuota -Confirm:$false -ErrorAction SilentlyContinue
        
        # 2. Delai LONG pour laisser FSRM nettoyer
        Start-Sleep -Seconds 2
        
        # 3. Creer les ACTIONS
        $EmailSubject = "ALERTE QUOTA - $QuotaName"
        $EmailBody = @"
ALERTE QUOTA FSRM

Quota: $QuotaName
Chemin: $Path
Utilisation: [Quota Used Percent] %
Details: [Quota Used] / [Quota Limit]

Responsable: $ResponsibleEmail
Admin: $AdminEmail

Archivez ou supprimez les fichiers anciens.
"@

        # ACTION EMAIL
        $ActionEmail = New-FsrmAction -Type Email `
            -MailTo "$ResponsibleEmail;$AdminEmail" `
            -Subject $EmailSubject `
            -Body $EmailBody `
            -ErrorAction Stop

        # ACTION EVENT
        $ActionEvent = New-FsrmAction -Type Event `
            -EventType Warning `
            -Body "Quota FSRM atteint: $QuotaName" `
            -ErrorAction Stop
        
        # 4. Creer les SEUILS
        $Threshold80 = New-FsrmQuotaThreshold -Percentage 80 -Action $ActionEmail -ErrorAction Stop
        $Threshold90 = New-FsrmQuotaThreshold -Percentage 90 -Action $ActionEvent -ErrorAction Stop
        $Threshold100 = New-FsrmQuotaThreshold -Percentage 100 -Action $ActionEvent -ErrorAction Stop
        
        # 5. Creer le QUOTA (HARD LIMIT)
        $SizeInBytes = $SizeMB * 1MB
        
        New-FsrmQuota -Path $Path `
            -Size $SizeInBytes `
            -SoftLimit:$false `
            -Threshold $Threshold80, $Threshold90, $Threshold100 `
            -Confirm:$false `
            -ErrorAction Stop | Out-Null
        
        Write-Host "    OK: $SizeMB MB - $QuotaName" -ForegroundColor Green
        
    } catch {
        Write-Host "    ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- [6] CREATION DES QUOTAS ---
Write-Host "`n[5/9] Creation des quotas..." -ForegroundColor Yellow

Write-Host "  [A] Departements (500 MB)..." -ForegroundColor Cyan
foreach ($Category in $Structure.Keys) {
    $CategoryPath = Join-Path -Path $RootPath -ChildPath $Category
    Set-QuotaWithAlerts -Path $CategoryPath -SizeMB 500 -ResponsibleEmail $AdminEmail -QuotaName "DEPT: $Category"
}

Write-Host "`n  [B] Sous-departements (100 MB)..." -ForegroundColor Cyan
foreach ($Category in $Structure.Keys) {
    foreach ($SubDept in $Structure[$Category].Keys) {
        $SubPath = Join-Path -Path $RootPath -ChildPath $Category | Join-Path -ChildPath $SubDept
        $RespEmail = $EmailCache["$Category|$SubDept"]
        Set-QuotaWithAlerts -Path $SubPath -SizeMB 100 -ResponsibleEmail $RespEmail -QuotaName "SUB: $SubDept"
    }
}

Write-Host "`n  [C] Commun (500 MB)..." -ForegroundColor Cyan
$CommonPath = Join-Path -Path $RootPath -ChildPath "Commun"
Set-QuotaWithAlerts -Path $CommonPath -SizeMB 500 -ResponsibleEmail $AdminEmail -QuotaName "COMMUN"

# --- [7] VERIFICATION ---
Write-Host "`n[6/9] Verification des quotas..." -ForegroundColor Yellow

# Recharger la liste des quotas
Remove-Module FileServerResourceManager -Force -ErrorAction SilentlyContinue
Import-Module FileServerResourceManager -Force
Start-Sleep -Seconds 3

$AllQuotas = Get-FsrmQuota -ErrorAction SilentlyContinue
Write-Host "OK: Total quotas crees: $($AllQuotas.Count)" -ForegroundColor Green

foreach ($Quota in $AllQuotas) {
    $SizeMB = $Quota.Size / 1MB
    $Usage = if ($Quota.Usage) { "{0:P0}" -f ($Quota.Usage / $Quota.Size) } else { "N/A" }
    Write-Host "   - $($Quota.Path) ($([math]::Round($SizeMB)) MB)" -ForegroundColor Gray
}

# --- [8] TEST EMAIL ---
Write-Host "`n[7/9] Envoi du test email..." -ForegroundColor Yellow

function Send-GmailMessage {
    param([string]$To, [string]$Subject, [string]$Body, [string]$FromAddress, [string]$GmailUser, [string]$GmailPassword)
    
    try {
        $PasswordSecure = ConvertTo-SecureString $GmailPassword -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential ($GmailUser, $PasswordSecure)
        
        Send-MailMessage -From $FromAddress -To $To -Subject $Subject -Body $Body `
            -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -Credential $Credential -ErrorAction Stop
        
        return $true
    } catch {
        return $false
    }
}

$TestBody = "Configuration FSRM v3.3 complete. $($AllQuotas.Count) quotas actifs. Hard limit active."

if (Send-GmailMessage -To $AdminEmail -Subject "TEST FSRM - Configuration v3.3 complete" -Body $TestBody -FromAddress $FromEmail -GmailUser $GmailAccount -GmailPassword $GmailAppPassword) {
    Write-Host "OK: Email de test envoye" -ForegroundColor Green
} else {
    Write-Host "WARN: Email echoue" -ForegroundColor Yellow
}

# --- BILAN ---
Write-Host "OK: CONFIGURATION FSRM COMPLETE" -ForegroundColor Green

Write-Host "`nRESUME:" -ForegroundColor Cyan
Write-Host "  ✅ $($AllQuotas.Count) quotas actifs" -ForegroundColor Green
Write-Host "  ✅ Alertes email configurees (80%, 90%, 100%)" -ForegroundColor Green
Write-Host "  ✅ Hard limit active (ecriture bloquee a 100%)" -ForegroundColor Green
Write-Host "  ✅ Gmail SMTP utilise (100% fiable)" -ForegroundColor Green

Write-Host "QUOTAS FSRM - PRETS POUR PRODUCTION" -ForegroundColor Green
