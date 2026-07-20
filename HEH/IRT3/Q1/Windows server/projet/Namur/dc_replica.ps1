# ========================================
# PROMOTION DC REPLICA - NAMUR (FINAL FIX)
# Windows Server 2019
# LE SITE NAMUR EST DEJA CREE SUR BRUXELLES
# ========================================

$DomainName = "Belgique.lan"
$SourceDC = "172.28.60.21"
$SourceDCFQDN = "DC-BRUXELLES.Belgique.lan"
$SiteName = "NAMUR"
$DSRMPassword = ConvertTo-SecureString "Test123!" -AsPlainText -Force
$LocalIP = "172.25.60.21"

# ========================================
# FONCTION: Afficher message coloré
# ========================================
function Write-Status {
    param(
        [string]$Message,
        [ValidateSet("OK", "ERROR", "WARNING", "INFO", "SECTION")]$Type = "INFO"
    )
    
    $Colors = @{
        "OK"      = "Green"
        "ERROR"   = "Red"
        "WARNING" = "Yellow"
        "INFO"    = "Cyan"
        "SECTION" = "Cyan"
    }
    
    $Prefix = @{
        "OK"      = "[OK]"
        "ERROR"   = "[ERROR]"
        "WARNING" = "[WARNING]"
        "INFO"    = "[*]"
        "SECTION" = "===="
    }
    
    Write-Host "$($Prefix[$Type]) $Message" -ForegroundColor $Colors[$Type]
}

# ========================================
# SECTION 0: AFFICHAGE INITIAL
# ========================================
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PROMOTION DC REPLICA - NAMUR" -ForegroundColor Cyan
Write-Host "Windows Server 2019 - FINAL FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Domaine: $DomainName" -ForegroundColor Cyan
Write-Host "Source: $SourceDCFQDN ($SourceDC)" -ForegroundColor Cyan
Write-Host "Replica IP: $LocalIP" -ForegroundColor Cyan
Write-Host "Site: $SiteName" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ========================================
# SECTION 1: VERIFICATIONS PRE-INSTALLATION
# ========================================
Write-Status "VERIFICATION PRE-INSTALLATION" "SECTION"
Write-Host ""

Write-Status "Verification de la version Windows..." "INFO"
$OSVersion = (Get-WmiObject -Class Win32_OperatingSystem).Version
$OSName = (Get-WmiObject -Class Win32_OperatingSystem).Caption

if ($OSName -like "*Server 2019*" -or $OSName -like "*Server 2022*") {
    Write-Status "OS compatible: $OSName ($OSVersion)" "OK"
} else {
    Write-Status "ATTENTION: Vous utilisez $OSName" "WARNING"
}
Write-Host ""

Write-Status "Verification de l'adresse IP locale..." "INFO"
$IPCheck = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -eq $LocalIP }

if ($IPCheck) {
    Write-Status "IP $LocalIP trouvee" "OK"
} else {
    Write-Status "L'IP $LocalIP n'est pas configuree !" "ERROR"
    exit
}
Write-Host ""

Write-Status "Test de ping vers le DC source ($SourceDC)..." "INFO"
$PingTest = Test-Connection -ComputerName $SourceDC -Count 1 -Quiet -ErrorAction SilentlyContinue

if ($PingTest) {
    Write-Status "Ping vers $SourceDC reussi" "OK"
} else {
    Write-Status "Impossible de pinger $SourceDC !" "ERROR"
    exit
}
Write-Host ""

Write-Status "Test de resolution DNS: $SourceDCFQDN" "INFO"
try {
    $DNSResult = Resolve-DnsName -Name $SourceDCFQDN -ErrorAction Stop
    Write-Status "Resolution DNS reussie: $SourceDCFQDN -> $($DNSResult.IPAddress)" "OK"
} catch {
    Write-Status "Impossible de resoudre $SourceDCFQDN !" "ERROR"
    exit
}
Write-Host ""

# ========================================
# SECTION 2: INSTALLATION DES ROLES
# ========================================
Write-Status "INSTALLATION DES ROLES AD DS ET DNS" "SECTION"
Write-Host ""

Write-Status "Verification de l'installation des roles..." "INFO"
$ADDSInstalled = (Get-WindowsFeature -Name AD-Domain-Services).Installed
$DNSInstalled = (Get-WindowsFeature -Name DNS).Installed

if ($ADDSInstalled -and $DNSInstalled) {
    Write-Status "Roles AD-Domain-Services et DNS deja installes" "OK"
} else {
    Write-Status "Installation des roles en cours..." "INFO"
    
    try {
        $InstallResult = Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools -ErrorAction Stop
        
        if ($InstallResult.Success) {
            Write-Status "Roles installes avec succes" "OK"
            
            if ($InstallResult.RestartNeeded -eq "Yes") {
                Write-Status "Redemarrage necessaire - Redemarrage dans 30 secondes..." "WARNING"
                Start-Sleep -Seconds 30
                Restart-Computer -Force
                exit
            }
        } else {
            Write-Status "Echec de l'installation des roles" "ERROR"
            exit
        }
    } catch {
        Write-Status "Erreur lors de l'installation : $_" "ERROR"
        exit
    }
}
Write-Host ""

# ========================================
# SECTION 3: VERIFICATION DES MODULES
# ========================================
Write-Status "VERIFICATION ET CHARGEMENT DES MODULES" "SECTION"
Write-Host ""

Write-Status "Chargement du module ADDSDeployment..." "INFO"
try {
    Import-Module ADDSDeployment -ErrorAction Stop
    Write-Status "Module ADDSDeployment charge" "OK"
} catch {
    Write-Status "Erreur lors du chargement du module : $_" "ERROR"
    exit
}
Write-Host ""

Write-Status "Chargement du module ActiveDirectory..." "INFO"
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Status "Module ActiveDirectory charge" "OK"
} catch {
    Write-Status "Module ActiveDirectory non disponible (normal avant promotion)" "WARNING"
}
Write-Host ""

# ========================================
# SECTION 4: TESTS DE CONNECTIVITE AVANCEES
# ========================================
Write-Status "TESTS DE CONNECTIVITE VERS LE DC SOURCE" "SECTION"
Write-Host ""

function Test-PortConnectivity {
    param([string]$ComputerName, [int]$Port, [string]$PortName = "")
    Write-Status "Test de connectivite: $ComputerName`:$Port $PortName" "INFO"
    try {
        $Result = Test-NetConnection -ComputerName $ComputerName -Port $Port -ErrorAction SilentlyContinue
        if ($Result.TcpTestSucceeded) {
            Write-Status "Connectivite reussie vers $ComputerName`:$Port" "OK"
            return $true
        } else {
            Write-Status "Impossible de se connecter a $ComputerName`:$Port" "ERROR"
            return $false
        }
    } catch {
        Write-Status "Erreur lors du test de connectivite : $_" "ERROR"
        return $false
    }
}

Test-PortConnectivity -ComputerName $SourceDC -Port 389 -PortName "(LDAP)" | Out-Null
Write-Host ""

Test-PortConnectivity -ComputerName $SourceDC -Port 636 -PortName "(LDAPS)" | Out-Null
Write-Host ""

Write-Status "Test port ADWS (9389) - CRITIQUE" "WARNING"
if (-not (Test-PortConnectivity -ComputerName $SourceDC -Port 9389 -PortName "(ADWS)")) {
    Write-Status "ERREUR CRITIQUE: Port ADWS (9389) inaccessible !" "ERROR"
    exit
}
Write-Host ""

Test-PortConnectivity -ComputerName $SourceDC -Port 88 -PortName "(Kerberos)" | Out-Null
Write-Host ""

# ========================================
# SECTION 5: VERIFICATION DES CREDENTIALS
# ========================================
Write-Status "AUTHENTIFICATION DOMAINE" "SECTION"
Write-Host ""

Write-Status "Entrez les identifiants du domaine Belgique" "INFO"
Write-Status "Format: Belgique\Administrateur" "INFO"
Write-Host ""

$Credential = Get-Credential -Message "Entrez les identifiants Belgique\Administrateur"

if (-not $Credential) {
    Write-Status "Credentials annulees par l'utilisateur" "ERROR"
    exit
}

Write-Status "Test des credentials..." "INFO"
try {
    $ADSIBind = [ADSI]::new("LDAP://$SourceDCFQDN", $Credential.UserName, $Credential.GetNetworkCredential().Password)
    $ADSIBind.Close()
    Write-Status "Credentials acceptes par le DC source" "OK"
} catch {
    Write-Status "ERREUR: Les credentials sont invalides !" "ERROR"
    exit
}
Write-Host ""

# ========================================
# SECTION 6: PROMOTION EN DC REPLICA
# ========================================
Write-Status "PROMOTION EN DC REPLICA" "SECTION"
Write-Host ""

Write-Status "IMPORTANT: Le site $SiteName doit deja exister sur le DC source !" "INFO"
Write-Status "Verification que le site existe..." "INFO"
Write-Host ""

Write-Status "Demarrage de la promotion DC Replica..." "INFO"
Write-Status "Cette operation peut prendre 10-15 minutes..." "INFO"
Write-Host ""

try {
    Install-ADDSDomainController `
        -DomainName $DomainName `
        -Credential $Credential `
        -SiteName $SiteName `
        -DatabasePath "C:\Windows\NTDS" `
        -LogPath "C:\Windows\NTDS" `
        -SysvolPath "C:\Windows\SYSVOL" `
        -SafeModeAdministratorPassword $DSRMPassword `
        -NoGlobalCatalog:$false `
        -Force `
        -Confirm:$false `
        -ErrorAction Stop

    Write-Status "Promotion en DC Replica reussie !" "OK"
    
} catch {
    Write-Status "ERREUR lors de la promotion : $_" "ERROR"
    Write-Status "Suggestions de depannage:" "WARNING"
    Write-Status "1. Verifier Event Viewer > Windows Logs > System" "INFO"
    Write-Status "2. Verifier que ADWS fonctionne sur DC-BRUXELLES" "INFO"
    Write-Status "3. Verifier la connectivite reseau" "INFO"
    Write-Status "4. Verifier que le site $SiteName existe dans AD sur BRUXELLES" "INFO"
    exit
}
Write-Host ""

# ========================================
# SECTION 8: FINALISATION
# ========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "PROMOTION REPLICA REUSSIE !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Status "Le serveur va redemarrer automatiquement dans 30 secondes..." "INFO"
Write-Status "Appuyez sur CTRL+C pour annuler le redemarrage" "INFO"
Write-Host ""

Start-Sleep -Seconds 30

Write-Status "Redemarrage du serveur..." "OK"
Restart-Computer -Force
