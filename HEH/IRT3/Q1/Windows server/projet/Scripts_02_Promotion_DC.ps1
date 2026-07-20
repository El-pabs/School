# SCRIPT 02A : Promotion DC ROOT BRUXELLE (Crée la forêt)



$DomainName = "Belgique.lan"
$SiteName = "BRUXELLE"
$DSRMPassword = ConvertTo-SecureString "P@ssword2025!DSRM" -AsPlainText -Force

Write-Host "PROMOTION DC ROOT - BRUXELLE" -ForegroundColor Cyan
Write-Host "Foret: $DomainName" -ForegroundColor Cyan
Write-Host "Site: $SiteName" -ForegroundColor Cyan

Write-Host "`n[VERIFICATION] Verification de l'IP..." -ForegroundColor Yellow

$IPCheck = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -eq "172.28.60.21" }

if ($IPCheck) {
    Write-Host "OK: IP 172.28.60.21 trouvee." -ForegroundColor Green
} else {
    Write-Host "ERREUR: L'IP 172.28.60.21 n'est pas configuree !" -ForegroundColor Red
    Break
}

Write-Host "`n[1/4] Installation des roles AD DS, DNS et DHCP..." -ForegroundColor Yellow

try {
    Install-WindowsFeature -Name AD-Domain-Services, DNS, DHCP -IncludeManagementTools
    Write-Host "OK: Roles installes" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: $_" -ForegroundColor Red
    Break
}

Write-Host "`n[2/4] Configuration DHCP pour VLANs..." -ForegroundColor Yellow

$DHCPScopes = @(
    @{ Name = "VLAN10-Admin";       Start = "172.28.10.3"; End = "172.28.10.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN20-RD";          Start = "172.28.20.3"; End = "172.28.20.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN30-IT";          Start = "172.28.30.3"; End = "172.28.30.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN40-Commercial";  Start = "172.28.40.3"; End = "172.28.40.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN50-Technique";   Start = "172.28.50.3"; End = "172.28.50.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN99-VoIP";        Start = "172.28.99.3"; End = "172.28.99.253"; Subnet = "255.255.255.0" }
)

foreach ($Scope in $DHCPScopes) {
    try {
        Add-DhcpServerv4Scope -Name $Scope.Name -StartRange $Scope.Start -EndRange $Scope.End -SubnetMask $Scope.Subnet -State Active -ErrorAction SilentlyContinue
        Write-Host "OK: Scope cree: $($Scope.Name)" -ForegroundColor Green
    } catch {
        Write-Host "ATTENTION: Scope existant: $($Scope.Name)" -ForegroundColor Gray
    }
}

Write-Host "`n[3/4] Promotion en DC Root..." -ForegroundColor Yellow

try {
    Import-Module ADDSDeployment

    Install-ADDSForest -DomainName $DomainName -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -LogPath "C:\Windows\NTDS" -SysvolPath "C:\Windows\SYSVOL" -SafeModeAdministratorPassword $DSRMPassword -Force -Confirm:$false

    Write-Host "OK: Foret creee !" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: $_" -ForegroundColor Red
    Break
}

Write-Host "OK: PROMOTION REUSSIE" -ForegroundColor Green
Write-Host "Redemarrage automatique du serveur..." -ForegroundColor Green

## SCRIPT 02B : Promotion DC REPLICA NAMUR
# Fichier: 02-Promo-DC-Replica-NAMUR.ps1

$DomainName = "Belgique.lan"
$SourceDC = "172.28.60.21"
$SourceDCFQDN = "DC-BRUXELLE.Belgique.lan"
$SiteName = "NAMUR"
$DSRMPassword = ConvertTo-SecureString "Test123!" -AsPlainText -Force

Write-Host "PROMOTION DC REPLICA - NAMUR" -ForegroundColor Cyan
Write-Host "Domaine: $DomainName" -ForegroundColor Cyan
Write-Host "Source: $SourceDCFQDN ($SourceDC)" -ForegroundColor Cyan
Write-Host "Site: $SiteName" -ForegroundColor Cyan

Write-Host "`n[VERIFICATION] Avant de continuer..." -ForegroundColor Yellow

$IPCheck = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -eq "172.25.60.21" }

if ($IPCheck) {
    Write-Host "OK: IP 172.25.60.21 trouvee." -ForegroundColor Green
} else {
    Write-Host "ERREUR: L'IP 172.25.60.21 n'est pas configuree !" -ForegroundColor Red
    Break
}

Write-Host "`nIMPORTANT: Verifiez que..." -ForegroundColor Yellow
Write-Host "  1. BRUXELLE (172.28.60.21) est demarree" -ForegroundColor Gray
Write-Host "  2. Routage entre 172.28.x.x et 172.25.60.x fonctionne" -ForegroundColor Gray

Write-Host "`nTest: ping 172.28.60.21" -ForegroundColor Cyan
$TestPing = Test-Connection -ComputerName $SourceDC -Count 1 -Quiet -ErrorAction SilentlyContinue

if ($TestPing) {
    Write-Host "OK: Ping reussi vers BRUXELLE" -ForegroundColor Green
} else {
    Write-Host "ERREUR: Impossible de ping BRUXELLE !" -ForegroundColor Red
    Write-Host "Verifiez le firewall et le routage" -ForegroundColor Red
    Break
}

Write-Host "`n[1/2] Installation des roles AD DS et DNS..." -ForegroundColor Yellow

try {
    Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools
    Write-Host "OK: Roles installes" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: $_" -ForegroundColor Red
    Break
}

Write-Host "`n[CREDENTIALS] Entrez les identifiants Belgique\Administrateur" -ForegroundColor Yellow
$Credential = Get-Credential -Message "Belgique\Administrateur"

if (-not $Credential) {
    Write-Host "ERREUR: Credentials annulees" -ForegroundColor Red
    Break
}

Write-Host "`n[2/2] Promotion en DC Replica..." -ForegroundColor Yellow

try {
    Import-Module ADDSDeployment

    New-ADReplicationSite -Name $SiteName -Confirm:$false -ErrorAction SilentlyContinue

    Install-ADDSDomainController -DomainName $DomainName -Credential $Credential -SiteName $SiteName -ReplicaOrNewDomain Replica -DatabasePath "C:\Windows\NTDS" -LogPath "C:\Windows\NTDS" -SysvolPath "C:\Windows\SYSVOL" -SafeModeAdministratorPassword $DSRMPassword -Force -Confirm:$false

    Write-Host "OK: Replica creee !" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: $_" -ForegroundColor Red
    Break
}

Write-Host "OK: PROMOTION REPLICA REUSSIE" -ForegroundColor Green
Write-Host "Redemarrage automatique du serveur..." -ForegroundColor Green

Write-Host "`nApres redemarrage sur NAMUR (DC Replica):" -ForegroundColor Cyan
Write-Host "  Connexion: BELGIQUE\Administrateur" -ForegroundColor Gray
Write-Host "  Lecture/Ecriture - Replica complet de Bruxelle" -ForegroundColor Gray

