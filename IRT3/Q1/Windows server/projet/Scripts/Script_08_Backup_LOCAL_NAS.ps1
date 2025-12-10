Write-Host "Creation des dossiers de backup..." -ForegroundColor Yellow
New-Item -Path "C:\Backups" -ItemType Directory -Force | Out-Null
New-Item -Path "C:\Backups\Logs" -ItemType Directory -Force | Out-Null
Write-Host "Dossiers crees/verifies" -ForegroundColor Green


# Configuration du serveur ACTUEL
$LocalServerName = $env:COMPUTERNAME
$LocalDomain = (Get-WmiObject Win32_ComputerSystem).Domain

Write-Host "SCRIPT DE SAUVEGARDE - BACKUP LOCAL + NAS" -ForegroundColor Cyan
Write-Host "Serveur: $LocalServerName" -ForegroundColor Yellow
Write-Host "Domaine: $LocalDomain" -ForegroundColor Yellow
Write-Host ""

# Configuration des chemins de sauvegarde
$BackupDirs = @(
    "C:\Windows\SYSVOL",
    "C:\Windows\NTDS",
    "C:\inetpub",
    "C:\Windows\System32\dhcp",
    "C:\Share"
)

# Chemins de sauvegarde
$LocalBackupPath = "C:\Backups"
$NASBackupPath = "\\192.168.2.198\Agence9"
$NASUsername = "Agence9"
$NASPassword = "Test1234*"

# Configuration du logging
$LogPath = "C:\Backups\Logs"
$LogFile = "$LogPath\Backup_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').log"
$BackupSummary = "$LogPath\BackupSummary_$(Get-Date -Format 'yyyy-MM-dd').csv"

# Configuration de retention
$RetentionDays = 7
$DeleteOldBackups = $true

# Variable globale pour la lettre de lecteur NAS
$global:NAS_Drive = $null

# ════════════════════════════════════════════════════════════════════════════
# [FONCTIONS UTILITAIRES]
# ════════════════════════════════════════════════════════════════════════════

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")][string]$Level = "INFO"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"

    switch ($Level) {
        "SUCCESS" { Write-Host $LogEntry -ForegroundColor Green }
        "WARNING" { Write-Host $LogEntry -ForegroundColor Yellow }
        "ERROR"   { Write-Host $LogEntry -ForegroundColor Red }
        default   { Write-Host $LogEntry -ForegroundColor Gray }
    }

    Add-Content -Path $LogFile -Value $LogEntry -ErrorAction SilentlyContinue
}

function Initialize-BackupEnvironment {
    Write-Log "Initialisation de l'environnement..." "INFO"

    if (-not (Test-Path $LocalBackupPath)) {
        New-Item -Path $LocalBackupPath -ItemType Directory -Force | Out-Null
        Write-Log "Dossier local cree: $LocalBackupPath" "SUCCESS"
    }

    if (-not (Test-Path $LogPath)) {
        New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
        Write-Log "Dossier logs cree: $LogPath" "SUCCESS"
    }

    Write-Log "Environnement initialise" "SUCCESS"
}

function Connect-NASShare {
    Write-Log "Connexion au partage NAS..." "INFO"

    try {
        $NASHost = "192.168.2.198"
        $TestConnection = Test-Connection -ComputerName $NASHost -Count 1 -Quiet -ErrorAction SilentlyContinue

        if (-not $TestConnection) {
            Write-Log "ERREUR: NAS non accessible ($NASHost)" "ERROR"
            return $false
        }

        Write-Log "NAS accessible: $NASHost" "SUCCESS"

        # Disconnect existing drives
        net use "$NASBackupPath" /delete /y 2>&1 | Out-Null

        # Find an available drive letter (Z to A)
        $DriveLetters = 90..65 | ForEach-Object { [char]$_ }
        $UsedDrives = (Get-PSDrive -PSProvider FileSystem).Name
        $AvailableDrive = $DriveLetters | Where-Object { $_ -notin $UsedDrives } | Select-Object -First 1

        if (-not $AvailableDrive) {
            Write-Log "ERREUR: Aucune lettre de lecteur disponible" "ERROR"
            return $false
        }

        Write-Log "Lettre de lecteur disponible: $AvailableDrive" "INFO"

        # FIX: Use net use instead of New-PSDrive for immediate connection
        $NetUseOutput = net use "$($AvailableDrive):" "$NASBackupPath" "/user:$NASUsername" "$NASPassword" 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "ERREUR connexion NAS (net use): $($NetUseOutput -join ' ')" "ERROR"
            return $false
        }

        Write-Log "Connexion NAS reussie: $NASBackupPath (lecteur $AvailableDrive``:)" "SUCCESS"
        
        # Store the drive letter for later use
        $global:NAS_Drive = $AvailableDrive
        return $true

    } catch {
        Write-Log "ERREUR connexion NAS: $_" "ERROR"
        return $false
    }
}

function Get-BackupFolderSize {
    param([string]$Path)

    if (Test-Path $Path) {
        $Size = (Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        return [Math]::Round($Size / 1GB, 2)
    }
    return 0
}

function Remove-OldBackups {
    param([string]$BackupPath, [int]$Days)

    Write-Log "Nettoyage des anciennes sauvegardes (> $Days jours)..." "INFO"

    $CutoffDate = (Get-Date).AddDays(-$Days)
    $DeletedCount = 0

    try {
        Get-ChildItem -Path $BackupPath -Filter "Backup_*" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $CutoffDate } | ForEach-Object {
            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
            $DeletedCount++
        }

        if ($DeletedCount -gt 0) {
            Write-Log "Nettoyage: $DeletedCount fichiers supprimes" "SUCCESS"
        }
    } catch {
        Write-Log "ERREUR nettoyage: $_" "WARNING"
    }
}

function Create-Backup {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [string]$BackupName
    )

    Write-Log "Sauvegarde: $SourcePath -> $DestinationPath" "INFO"

    try {
        $BackupFolder = "$DestinationPath\$BackupName"

        if (-not (Test-Path $BackupFolder)) {
            New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null
        }

        $RobocopyArgs = @(
            $SourcePath,
            $BackupFolder,
            "/S",
            "/E",
            "/COPY:DAT",
            "/R:3",
            "/W:5",
            "/MT:8",
            "/LOG:$LogPath\robocopy_$BackupName.log"
        )

        & robocopy $RobocopyArgs | Out-Null

        $BackupSize = Get-BackupFolderSize -Path $BackupFolder
        Write-Log "Backup OK: $BackupName ($BackupSize GB)" "SUCCESS"

        return @{
            Name = $BackupName
            Path = $BackupFolder
            Size = $BackupSize
            Timestamp = Get-Date
            Status = "SUCCESS"
        }

    } catch {
        Write-Log "ERREUR backup $SourcePath : $_" "ERROR"
        return @{
            Name = $BackupName
            Status = "FAILED"
            Error = $_
        }
    }
}

function Export-BackupSummary {
    param([array]$BackupResults)

    Write-Log "Export du resume de sauvegarde..." "INFO"

    try {
        $Summary = @()

        foreach ($Result in $BackupResults) {
            $Summary += [PSCustomObject]@{
                Serveur = $LocalServerName
                Domaine = $LocalDomain
                BackupName = $Result.Name
                Chemin = $Result.Path
                TailleGB = $Result.Size
                Timestamp = $Result.Timestamp
                Status = $Result.Status
                Erreur = if ($Result.Error) { $Result.Error.ToString() } else { "N/A" }
            }
        }

        $Summary | Export-Csv -Path $BackupSummary -Delimiter ";" -Encoding UTF8 -NoTypeInformation -Append
        Write-Log "Resume exporte: $BackupSummary" "SUCCESS"
    } catch {
        Write-Log "ERREUR export resume: $_" "WARNING"
    }
}

$StartTime = Get-Date
$BackupResults = @()

Write-Log "Demarrage de la sauvegarde" "INFO"
Write-Log "Serveur: $LocalServerName" "INFO"
Write-Log "Domaine: $LocalDomain" "INFO"

# Etape 1: Initialisation
Initialize-BackupEnvironment

# Etape 2: Sauvegarde LOCALE
Write-Log "PHASE 1: Sauvegarde LOCALE" "INFO"
Write-Host ""
Write-Host "[PHASE 1] Sauvegarde LOCALE" -ForegroundColor Cyan
Write-Host ""

foreach ($Dir in $BackupDirs) {
    if (Test-Path $Dir) {
        $FolderName = Split-Path -Leaf $Dir
        $BackupName = "Backup_$FolderName`_$(Get-Date -Format 'yyyy-MM-dd_HHmmss')"

        $Result = Create-Backup -SourcePath $Dir -DestinationPath $LocalBackupPath -BackupName $BackupName
        $BackupResults += $Result

        Start-Sleep -Seconds 2
    }
}

# Etape 3: Nettoyage des anciennes backups LOCALES
if ($DeleteOldBackups) {
    Remove-OldBackups -BackupPath $LocalBackupPath -Days $RetentionDays
}

# Etape 4: Connexion NAS et sauvegarde
Write-Log "PHASE 2: Sauvegarde NAS" "INFO"
Write-Host ""
Write-Host "[PHASE 2] Sauvegarde NAS" -ForegroundColor Cyan
Write-Host ""

if (Connect-NASShare) {
    foreach ($Dir in $BackupDirs) {
        if (Test-Path $Dir) {
            $FolderName = Split-Path -Leaf $Dir
            $BackupName = "Backup_$FolderName`_$(Get-Date -Format 'yyyy-MM-dd_HHmmss')"

            $NASDestination = "$($global:NAS_Drive):\$LocalServerName"

            if (-not (Test-Path $NASDestination)) {
                New-Item -Path $NASDestination -ItemType Directory -Force | Out-Null
            }

            $Result = Create-Backup -SourcePath $Dir -DestinationPath $NASDestination -BackupName $BackupName
            $BackupResults += $Result

            Start-Sleep -Seconds 2
        }
    }

    if ($DeleteOldBackups) {
        Remove-OldBackups -BackupPath "$($global:NAS_Drive):\$LocalServerName" -Days $RetentionDays
    }

    # Disconnect the NAS drive
    net use "$($global:NAS_Drive):" /delete /y 2>&1 | Out-Null
}

# Etape 5: Calcul des statistiques finales
Write-Log "PHASE 3: Calcul des statistiques" "INFO"
Write-Host ""
Write-Host "[PHASE 3] Calcul des statistiques" -ForegroundColor Cyan
Write-Host ""

$TotalLocalBackupSize = Get-BackupFolderSize -Path $LocalBackupPath
$TotalBackupCount = ($BackupResults | Where-Object { $_.Status -eq "SUCCESS" }).Count
$FailedBackupCount = ($BackupResults | Where-Object { $_.Status -eq "FAILED" }).Count

# Etape 6: Export du resume
Export-BackupSummary -BackupResults $BackupResults

# Etape 7: Rapport final
$EndTime = Get-Date
$Duration = New-TimeSpan -Start $StartTime -End $EndTime

Write-Log "RESUME DE SAUVEGARDE" "INFO"
Write-Log "Serveur: $LocalServerName" "INFO"
Write-Log "Debut: $StartTime" "INFO"
Write-Log "Fin: $EndTime" "INFO"
Write-Log "Duree totale: $($Duration.TotalMinutes) minutes" "INFO"
Write-Log "Backups reussis: $TotalBackupCount" "SUCCESS"
Write-Log "Backups echoues: $FailedBackupCount" "WARNING"
Write-Log "Taille totale locale: $TotalLocalBackupSize GB" "INFO"
Write-Log "Chemin local: $LocalBackupPath" "INFO"
Write-Log "Chemin NAS: $NASBackupPath" "INFO"
Write-Log "Fichier log: $LogFile" "INFO"

Write-Host ""
Write-Host "SAUVEGARDE TERMINEES" -ForegroundColor Green
Write-Host ""
Write-Host "Resume:" -ForegroundColor Cyan
Write-Host "  - Backups reussis: $TotalBackupCount" -ForegroundColor Green
Write-Host "  - Backups echoues: $FailedBackupCount" -ForegroundColor Yellow
Write-Host "  - Taille totale: $TotalLocalBackupSize GB" -ForegroundColor Green
Write-Host "  - Chemin local: $LocalBackupPath" -ForegroundColor Green
Write-Host "  - Chemin NAS: $NASBackupPath" -ForegroundColor Green
Write-Host "  - Logs: $LogFile" -ForegroundColor Green
Write-Host ""
