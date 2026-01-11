Write-Host "PREPARATION DC-BRUXELLES" -ForegroundColor Cyan
Write-Host "Installation/Configuration ADWS + Site NAMUR" -ForegroundColor Cyan
Write-Host ""

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


Write-Status "VERIFICATION PERMISSIONS" "SECTION"
Write-Host ""

$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $IsAdmin) {
    Write-Status "ERREUR: Ce script doit etre execute en tant qu'Administrateur !" "ERROR"
    Write-Status "Relance PowerShell en tant qu'Administrateur" "ERROR"
    exit
}

Write-Status "Permissions Administrateur confirmees" "OK"
Write-Host ""


Write-Status "VERIFICATION/INSTALLATION DU SERVICE ADWS" "SECTION"
Write-Host ""

# 1.1 Charger les modules necessaires
Write-Status "Chargement des modules..." "INFO"
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Status "Module ActiveDirectory charge" "OK"
} catch {
    Write-Status "ERREUR: Module ActiveDirectory non disponible" "ERROR"
    Write-Status "Ce serveur n'est peut-etre pas un Domain Controller !" "ERROR"
    exit
}
Write-Host ""

# 1.2 Verifier que c'est un DC
Write-Status "Verification que c'est un Domain Controller..." "INFO"
try {
    $DCCheck = Get-ADDomainController -Identity (hostname) -ErrorAction SilentlyContinue
    
    if ($DCCheck) {
        Write-Status "Domain Controller confirme: $(hostname)" "OK"
    } else {
        Write-Status "ERREUR: Pas un Domain Controller !" "ERROR"
        exit
    }
} catch {
    Write-Status "ERREUR: Impossible de verifier le DC" "ERROR"
    exit
}
Write-Host ""

# 1.3 Verifier l'etat du service ADWS
Write-Status "Verification de l'etat du service ADWS..." "INFO"
try {
    $ADWSService = Get-Service -Name ADWS -ErrorAction SilentlyContinue
    
    if ($ADWSService) {
        Write-Status "Service ADWS trouve" "OK"
        Write-Host "  Name: $($ADWSService.Name)" -ForegroundColor Gray
        Write-Host "  Status: $($ADWSService.Status)" -ForegroundColor Gray
        Write-Host "  StartType: $($ADWSService.StartType)" -ForegroundColor Gray
        
        # 1.4 Si le service n'est pas en cours d'exécution, le démarrer
        if ($ADWSService.Status -ne "Running") {
            Write-Status "Le service ADWS n'est pas demarree, demarrage..." "WARNING"
            Start-Service -Name ADWS -ErrorAction Stop
            Start-Sleep -Seconds 2
            Write-Status "Service ADWS demarree" "OK"
        } else {
            Write-Status "Le service ADWS est deja en cours d'execution" "OK"
        }
        
        # 1.5 Verifier que le service est parametre pour demarrage automatique
        if ($ADWSService.StartType -ne "Automatic") {
            Write-Status "Configuration du demarrage automatique..." "INFO"
            Set-Service -Name ADWS -StartupType Automatic -ErrorAction Stop
            Write-Status "Demarrage automatique configure" "OK"
        } else {
            Write-Status "Demarrage automatique deja configure" "OK"
        }
    } else {
        Write-Status "ERREUR: Service ADWS non trouve !" "ERROR"
        Write-Status "Ce serveur n'est peut-etre pas un Domain Controller !" "ERROR"
        exit
    }
} catch {
    Write-Status "ERREUR lors de la gestion du service ADWS: $_" "ERROR"
    exit
}
Write-Host ""

# 1.6 Verifier que le service est bien demarree apres modification
Write-Status "Verification finale du service ADWS..." "INFO"
try {
    $ADWSVerify = Get-Service -Name ADWS -ErrorAction Stop
    
    if ($ADWSVerify.Status -eq "Running") {
        Write-Status "Service ADWS: DEMARREE (RUNNING)" "OK"
    } else {
        Write-Status "ERREUR: Service ADWS n'est pas demarree !" "ERROR"
        Write-Status "Verifie manuellement: Get-Service ADWS" "WARNING"
        exit
    }
} catch {
    Write-Status "ERREUR lors de la verification: $_" "ERROR"
    exit
}
Write-Host ""

Write-Status "VERIFICATION DU PORT 9389 (ADWS)" "SECTION"
Write-Host ""

Write-Status "Verification que le port 9389 est en ecoute..." "INFO"
try {
    # Utiliser Test-NetConnection au lieu de netstat
    $TCPCheck = Get-NetTCPConnection -LocalPort 9389 -State Listen -ErrorAction SilentlyContinue
    
    if ($TCPCheck) {
        Write-Status "Port 9389 en ecoute !" "OK"
        Write-Host "  Etat: LISTEN" -ForegroundColor Gray
        Write-Host "  Adresse locale: $($TCPCheck.LocalAddress)" -ForegroundColor Gray
        Write-Host "  PID du processus: $($TCPCheck.OwningProcess)" -ForegroundColor Gray
    } else {
        Write-Status "ATTENTION: Port 9389 ne semble pas en ecoute" "WARNING"
        Write-Status "Redemarrage du service ADWS..." "INFO"
        Restart-Service -Name ADWS -Force -ErrorAction Stop
        Start-Sleep -Seconds 5
        
        $TCPCheck2 = Get-NetTCPConnection -LocalPort 9389 -State Listen -ErrorAction SilentlyContinue
        if ($TCPCheck2) {
            Write-Status "Port 9389 maintenant en ecoute apres redemarrage" "OK"
        } else {
            Write-Status "ERREUR: Port 9389 toujours pas en ecoute apres redemarrage" "ERROR"
            Write-Status "Verifications supplementaires:" "WARNING"
            Write-Status "  1. Get-Service ADWS | Select-Object Status" "INFO"
            Write-Status "  2. Get-NetTCPConnection -LocalPort 9389" "INFO"
            Write-Status "  3. Verifie le pare-feu Windows" "INFO"
            exit
        }
    }
} catch {
    Write-Status "ERREUR lors de la verification du port: $_" "ERROR"
    Write-Status "Utilisation de Get-NetTCPConnection..." "WARNING"
    
    try {
        $Connections = Get-NetTCPConnection -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -eq 9389 -and $_.State -eq "Listen" }
        
        if ($Connections) {
            Write-Status "Port 9389 ACTIF (detalle via Get-NetTCPConnection)" "OK"
        } else {
            Write-Status "Port 9389 N'EST PAS EN ECOUTE" "ERROR"
            exit
        }
    } catch {
        Write-Status "Impossible de verifier - Redemarrage ADWS..." "WARNING"
        Restart-Service -Name ADWS -Force
        Start-Sleep -Seconds 5
        Write-Status "Service ADWS redemarrare" "OK"
    }
}
Write-Host ""


Write-Status "CREATION/VERIFICATION DU SITE NAMUR" "SECTION"
Write-Host ""

Write-Status "Verification que le site NAMUR existe..." "INFO"
try {
    $SiteCheck = Get-ADReplicationSite -Filter { Name -eq "NAMUR" } -ErrorAction SilentlyContinue
    
    if ($SiteCheck) {
        Write-Status "Le site NAMUR existe deja" "OK"
        Write-Host "  Name: $($SiteCheck.Name)" -ForegroundColor Gray
        Write-Host "  DN: $($SiteCheck.DistinguishedName)" -ForegroundColor Gray
    } else {
        Write-Status "Le site NAMUR n'existe pas, creation..." "INFO"
        New-ADReplicationSite -Name "NAMUR" -Confirm:$false -ErrorAction Stop
        Write-Status "Site NAMUR cree" "OK"
        Start-Sleep -Seconds 2
    }
} catch {
    Write-Status "ERREUR lors de la creation du site: $_" "ERROR"
    exit
}
Write-Host ""

Write-Status "VERIFICATION FINALE" "SECTION"
Write-Host ""

Write-Status "Liste de tous les sites AD:" "INFO"
try {
    $AllSites = Get-ADReplicationSite -Filter * -ErrorAction Stop
    Write-Host "  Sites trouves:" -ForegroundColor Gray
    $AllSites | ForEach-Object { Write-Host "    - $($_.Name)" -ForegroundColor Gray }
    
    if ($AllSites | Where-Object { $_.Name -eq "NAMUR" }) {
        Write-Status "Site NAMUR confirme dans Active Directory" "OK"
    } else {
        Write-Status "ATTENTION: Site NAMUR introuvable !" "WARNING"
    }
} catch {
    Write-Status "ERREUR lors de la lecture des sites: $_" "ERROR"
}
Write-Host ""

Write-Host ""

Write-Status "Resume:" "OK"

