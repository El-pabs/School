# ════════════════════════════════════════════════════════════════════════════
# SCRIPT : CONFIGURER RELAIS SMTP VIA IIS 6.0 MANAGER
# Fichier: Setup-SMTP-Relay-IIS.ps1
# 
# FONCTION:
#   - Configure le relais SMTP via IIS 6.0 Manager (GUI automatisee)
#   - Configure FSRM manuellement (plus simple)
# ════════════════════════════════════════════════════════════════════════════

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "CONFIGURATION RELAIS SMTP - METHODE IIS MANAGER" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

# Verifier si exécuté en tant qu'administrateur
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`nERREUR: Ce script doit etre execute en tant qu'Administrateur !" -ForegroundColor Red
    exit
}

Write-Host "`n[1/4] Verification du service SMTP..." -ForegroundColor Yellow

# Verifier si SMTP est installe
$SmtpService = Get-Service -Name SMTPSVC -ErrorAction SilentlyContinue
if (-not $SmtpService) {
    Write-Host "Installation du service SMTP..." -ForegroundColor Gray
    Install-WindowsFeature SMTP-Server -IncludeManagementTools -ErrorAction Stop | Out-Null
    Write-Host "OK: SMTP installe !" -ForegroundColor Green
} else {
    Write-Host "OK: Service SMTP deja present" -ForegroundColor Green
}

# Demarrer le service
if ($SmtpService.Status -ne "Running") {
    Write-Host "Demarrage du service SMTP..." -ForegroundColor Gray
    Start-Service -Name SMTPSVC -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

Write-Host "`n[2/4] Configuration du relais SMTP..." -ForegroundColor Yellow
Write-Host "La configuration se fera via IIS 6.0 Manager (interface graphique)" -ForegroundColor Cyan

Write-Host "`nSUIVEZ CES ETAPES:" -ForegroundColor Yellow
Write-Host "`n1. Ouvre IIS 6.0 Manager (cherche 'IIS 6.0' dans Demarrer)" -ForegroundColor White
Write-Host "2. Developpe 'Computer' (a gauche)" -ForegroundColor White
Write-Host "3. Clic droit sur 'SMTP Virtual Server #1'" -ForegroundColor White
Write-Host "4. Clique sur 'Properties'" -ForegroundColor White

Write-Host "`n[ONGLET: GENERAL]" -ForegroundColor Cyan
Write-Host "  - IP Address: All Unassigned" -ForegroundColor Gray
Write-Host "  - TCP Port: 25" -ForegroundColor Gray
Write-Host "  Clique: Apply" -ForegroundColor White

Write-Host "`n[ONGLET: ACCESS]" -ForegroundColor Cyan
Write-Host "  1. Clique sur le bouton 'Relay...'" -ForegroundColor White
Write-Host "  2. Selectionne 'Only the list below'" -ForegroundColor White
Write-Host "  3. Ajoute: 127.0.0.1" -ForegroundColor Cyan
Write-Host "  4. OK" -ForegroundColor White

Write-Host "`n[ONGLET: DELIVERY]" -ForegroundColor Cyan

Write-Host "`n  A. OUTBOUND SECURITY:" -ForegroundColor White
Write-Host "     1. Clique: 'Outbound Security...'" -ForegroundColor Gray
Write-Host "     2. Coche 'Basic authentication'" -ForegroundColor Gray
Write-Host "     3. Username: fsrm.belgique@gmail.com" -ForegroundColor Cyan
Write-Host "     4. Password: dzlh yqgi sscq lrmm" -ForegroundColor Cyan
Write-Host "     5. Coche 'TLS encryption'" -ForegroundColor Gray
Write-Host "     6. OK" -ForegroundColor Gray

Write-Host "`n  B. OUTBOUND CONNECTIONS:" -ForegroundColor White
Write-Host "     1. Clique: 'Outbound Connections...'" -ForegroundColor Gray
Write-Host "     2. Port: 587" -ForegroundColor Cyan
Write-Host "     3. OK" -ForegroundColor Gray

Write-Host "`n  C. ADVANCED (Smart Host):" -ForegroundColor White
Write-Host "     1. Clique: 'Advanced...'" -ForegroundColor Gray
Write-Host "     2. 'Outbound Mail Server (Smart Host)': smtp.gmail.com" -ForegroundColor Cyan
Write-Host "     3. OK" -ForegroundColor Gray

Write-Host "`n[ONGLET: MESSAGES]" -ForegroundColor Cyan
Write-Host "  - Laisse les parametres par defaut" -ForegroundColor Gray
Write-Host "  - Clique: Apply" -ForegroundColor White

Write-Host "`nUne fois termine, clique: OK" -ForegroundColor White

Write-Host "`n[3/4] Configuration de FSRM..." -ForegroundColor Yellow

Write-Host "`nSUIVEZ CES ETAPES:" -ForegroundColor Yellow
Write-Host "`n1. Ouvre FSRM Manager (tapez 'fsrm.msc' dans Demarrer)" -ForegroundColor White
Write-Host "2. Clic droit sur 'File Server Resource Manager'" -ForegroundColor White
Write-Host "3. Clique 'Configure Options...'" -ForegroundColor White
Write-Host "4. Va a l'onglet 'Email Notifications'" -ForegroundColor White

Write-Host "`nRemplis les champs:" -ForegroundColor Cyan
Write-Host "  - SMTP server name or IP address: 127.0.0.1" -ForegroundColor Cyan
Write-Host "  - Default 'From' e-mail address: fsrm.belgique@gmail.com" -ForegroundColor Cyan
Write-Host "  - Default administrator recipients: robin.gillard1@std.heh.be" -ForegroundColor Cyan

Write-Host "`nClique: 'Send Test E-mail'" -ForegroundColor White
Write-Host "  - Tu devrais recevoir l'email de test en quelques secondes" -ForegroundColor Gray

Write-Host "`nClique: OK" -ForegroundColor White

Write-Host "`n[4/4] Test des alertes de quota..." -ForegroundColor Yellow

Write-Host "`nUne fois que FSRM est configure, lance ce script:" -ForegroundColor Cyan
Write-Host "  .\Test-FsrmAlert.ps1" -ForegroundColor White

Write-Host "`n===================================================" -ForegroundColor Green
Write-Host "CONFIGURATION MANUELLE TERMINEE" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green

Write-Host "`nRESUME:" -ForegroundColor Cyan
Write-Host "  1. IIS SMTP Server: Configuré pour relayer vers Gmail" -ForegroundColor Green
Write-Host "  2. FSRM: Envoie les emails au serveur local (127.0.0.1)" -ForegroundColor Green
Write-Host "  3. Flux: FSRM -> 127.0.0.1:25 -> smtp.gmail.com:587" -ForegroundColor Green

Write-Host "`nCOMMANDES UTILES:" -ForegroundColor Cyan
Write-Host "  Redemarrer SMTP:" -ForegroundColor Gray
Write-Host "    Restart-Service SMTPSVC" -ForegroundColor White
Write-Host "  Voir l'etat:" -ForegroundColor Gray
Write-Host "    Get-Service SMTPSVC" -ForegroundColor White
Write-Host "  Logs SMTP:" -ForegroundColor Gray
Write-Host "    C:\Inetpub\mailroot\" -ForegroundColor White

Write-Host "`n===================================================" -ForegroundColor Cyan
Write-Host "FIN DU SCRIPT" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

Write-Host "`nAppuie sur une touche pour fermer..." -ForegroundColor Gray
[Console]::ReadKey($true) | Out-Null
