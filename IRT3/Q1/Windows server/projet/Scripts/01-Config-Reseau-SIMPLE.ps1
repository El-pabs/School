
# --- BRUXELLE (DC ROOT - Maitre) ---
$ServerName = "DC-BRUXELLES"
$IPAddress = "172.28.60.21"
$PrefixLength = 24
$Gateway = "172.28.60.1"
$DNS = "127.0.0.1"

# --- NAMUR (DC REPLICA - Secondaire) ---
# $ServerName = "DC-NAMUR"
# $IPAddress = "172.25.60.21"
# $PrefixLength = 24
# $Gateway = "172.25.60.1"
# $DNS = "172.28.60.21"

# --- MONS (RODC - Read Only) ---
# $ServerName = "DC-MONS-RO"
# $IPAddress = "172.27.60.21"
# $PrefixLength = 24
# $Gateway = "172.27.60.1"
# $DNS = "172.25.60.21"


if (-not $ServerName) {
    Write-Host "ERREUR: Vous n'avez pas decommente la section du serveur en haut du script !" -ForegroundColor Red
    Break
}

Write-Host "CONFIGURATION : $ServerName" -ForegroundColor Cyan
Write-Host "IP: $IPAddress / GW: $Gateway" -ForegroundColor Cyan

# 1. Configurer l'IP
Write-Host "`n[1/3] Configuration IP..." -ForegroundColor Yellow
$Interface = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1

# Nettoyage
Remove-NetIPAddress -InterfaceAlias $Interface.Name -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetRoute -InterfaceAlias $Interface.Name -Confirm:$false -ErrorAction SilentlyContinue

# Nouvelle IP + Gateway
New-NetIPAddress -InterfaceAlias $Interface.Name -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway -AddressFamily IPv4
Set-DnsClientServerAddress -InterfaceAlias $Interface.Name -ServerAddresses $DNS

# 2. Renommer le serveur
Write-Host "`n[2/3] Renommage du serveur..." -ForegroundColor Yellow
Rename-Computer -NewName $ServerName -Force -ErrorAction SilentlyContinue

# 3. Test Ping Gateway
Write-Host "`n[3/3] Test connexion Gateway ($Gateway)..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
if (Test-Connection -ComputerName $Gateway -Count 1 -Quiet) {
    Write-Host "   OK: Ping Gateway reussi !" -ForegroundColor Green
} else {
    Write-Host "   ATTENTION: Ping Gateway echoue. Verifiez votre VLAN ou Firewall." -ForegroundColor Red
}

Write-Host "TERMINE ! Le serveur va redémarrer dans 5 secondes..." -ForegroundColor Green
Start-Sleep -Seconds 5
Restart-Computer -Force
