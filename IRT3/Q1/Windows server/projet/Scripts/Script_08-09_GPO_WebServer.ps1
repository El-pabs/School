Write-Host " SERVEUR WEB HTTPS                                             " -ForegroundColor Cyan

Write-Host "`n[1/3] Installation de IIS..." -ForegroundColor Yellow

try {
    Install-WindowsFeature Web-Server -IncludeManagementTools -ErrorAction Stop
    Write-Host "   ✅ IIS installé" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  IIS déjà installé" -ForegroundColor Gray
}

# Créer le site Web
Write-Host "`n[2/3] Configuration du site web..." -ForegroundColor Yellow

$WebPath = "C:\inetpub\wwwroot"

Set-Content -Path "$WebPath\index.html" -Value @"
<!DOCTYPE html>
<html>
<head>
    <title>Belgique.LAN</title>
    <style>
        body { font-family: Arial; text-align: center; margin-top: 50px; }
        h1 { color: #1C5A96; }
        .secure { color: green; font-size: 14px; }
    </style>
</head>
<body>
    <h1>Bienvenue sur Belgique.LAN</h1>
    <p>Portail d'accès sécurisé</p>
    <p class="secure">✅ Connexion HTTPS sécurisée</p>
</body>
</html>
"@

Write-Host "   ✅ Site web créé" -ForegroundColor Green

# Créer certificat SSL auto-signé
Write-Host "`n[3/3] Configuration HTTPS..." -ForegroundColor Yellow

try {
    $Cert = New-SelfSignedCertificate -DnsName "www.Belgique.lan", "Belgique.lan" -CertStoreLocation "cert:\LocalMachine\My" -FriendlyName "Belgique Web" -ErrorAction SilentlyContinue
    
    # Ajouter binding HTTPS
    New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https -HostHeader "www.Belgique.lan" -ErrorAction SilentlyContinue
    
    # Associer le certificat
    $Binding = Get-WebBinding -Protocol https -HostHeader "www.Belgique.lan"
    $Binding.AddSslCertificate($Cert.Thumbprint, "My")
    
    Write-Host "   ✅ Certificat SSL créé et configuré" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Certificat déjà existant" -ForegroundColor Gray
}

Write-Host " ✅ SERVEUR WEB CONFIGURÉ                                      " -ForegroundColor Green

Write-Host "`nAccès:" -ForegroundColor Cyan
Write-Host "   HTTPS: https://www.Belgique.lan" -ForegroundColor Gray
Write-Host "   (Certificat auto-signé = avertissement navigateur)" -ForegroundColor Gray