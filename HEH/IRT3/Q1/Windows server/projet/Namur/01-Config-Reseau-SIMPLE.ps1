# ════════════════════════════════════════════════════════════════════════════
# SCRIPT 01 : Configuration réseau - SIMPLE ET ROBUSTE
# À adapter selon le serveur en changeant les variables
# ════════════════════════════════════════════════════════════════════════════

# 🔑 MODIFIER CES VARIABLES SELON LE SERVEUR
$ServerName = "DC-NAMUR"
$IPAddress = "172.25.60.21"
$PrefixLength = 24
$DNS = "172.28.60.21"

# ════════════════════════════════════════════════════════════════════════════

Write-Host "Configuration de l'adresse IP..." -ForegroundColor Cyan
$Interface = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1

Remove-NetIPAddress -InterfaceAlias $Interface.Name -Confirm:$false -ErrorAction SilentlyContinue

New-NetIPAddress -InterfaceAlias $Interface.Name -IPAddress $IPAddress -PrefixLength $PrefixLength -AddressFamily IPv4

Set-DnsClientServerAddress -InterfaceAlias $Interface.Name -ServerAddresses $DNS

Write-Host "Renommage du serveur en $ServerName..." -ForegroundColor Cyan
Rename-Computer -NewName $ServerName -Force

Write-Host "Le serveur va redémarrer dans 5 secondes..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
Restart-Computer -Force