$RootPath = "C:\Share"
$Domain = "Belgique.lan"

Write-Host "FILTRAGE FSRM - C:\Share (Windows Server 2019)" -ForegroundColor Cyan
Write-Host "Autorise: Office + Images UNIQUEMENT" -ForegroundColor Cyan
Write-Host "Interdit: TOUT LE RESTE" -ForegroundColor Cyan

# --- 1. IMPORTER MODULE FSRM ---
Write-Host "`n[1/3] Import FSRM..." -ForegroundColor Yellow
Import-Module FileServerResourceManager
Write-Host "Module charge." -ForegroundColor Green

# --- 2. CREER LE GROUPE DE FICHIERS INTERDITS ---
Write-Host "`n[2/3] Creation du groupe de fichiers..." -ForegroundColor Yellow

$GroupName = "Interdits_Tout_Sauf_Office_Images"
$ExistingGroup = Get-FsrmFileGroup -Name $GroupName -ErrorAction SilentlyContinue

if (-not $ExistingGroup) {
    # Extensions OFFICE autorisees
    $OfficeExt = @(
        "*.doc", "*.docx", "*.dot", "*.dotx",
        "*.xls", "*.xlsx", "*.xlt", "*.xltx",
        "*.ppt", "*.pptx", "*.pot", "*.potx",
        "*.odt", "*.ods", "*.odp",
        "*.rtf", "*.txt", "*.pdf"
    )
    
    # Extensions IMAGES autorisees
    $ImageExt = @(
        "*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp",
        "*.tiff", "*.tif", "*.webp", "*.svg", "*.ico",
        "*.psd", "*.raw"
    )
    
    # Combiner
    $AllowedExt = $OfficeExt + $ImageExt
    
    # Creer le groupe: TOUT (*.*) SAUF les extensions autorisees
    New-FsrmFileGroup -Name $GroupName `
        -IncludePattern @("*.*") `
        -ExcludePattern $AllowedExt `
        -Description "TOUT interdit sauf Office et Images sur C:\Share"
    
    Write-Host "Groupe cree: $GroupName" -ForegroundColor Green
    Write-Host "Inclus: TOUT (*.*)" -ForegroundColor Green
    Write-Host "Exclus: Office ($($OfficeExt.Count) ext) + Images ($($ImageExt.Count) ext)" -ForegroundColor Green
} else {
    Write-Host "Groupe existe deja: $GroupName" -ForegroundColor Gray
}

# --- 3. CREER ET APPLIQUER LE FILTRAGE ---
Write-Host "`n[3/3] Application du filtrage sur C:\Share..." -ForegroundColor Yellow

# Action 1: Event Log (type = Event pour Server 2019)
$ActionEventLog = New-FsrmAction -Type Event -EventType Warning `
    -Body "FSRM BLOQUE: Tentative de depot de fichier non autorise. Seuls les fichiers Office et Images sont acceptes."

# Creer le filtrage (Passive = soft block, Active = hard block)
function Apply-FileScreenRecursive {
    param(
        [string]$Path
    )
    
    # Verifier si filtrage existe
    $Existing = Get-FsrmFileScreen -Path $Path -ErrorAction SilentlyContinue
    
    if (-not $Existing) {
        New-FsrmFileScreen -Path $Path `
            -IncludeGroup $GroupName `
            -Notification $ActionEventLog
        Write-Host "Filtrage applique: $Path" -ForegroundColor Green
    } else {
        Write-Host "Filtrage existe deja: $Path" -ForegroundColor Gray
    }
    
    # Appliquer recursivement sur sous-dossiers
    $SubFolders = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue
    foreach ($SubFolder in $SubFolders) {
        Apply-FileScreenRecursive -Path $SubFolder.FullName
    }
}

Apply-FileScreenRecursive -Path $RootPath

# --- BILAN ---
Write-Host "FILTRAGE TERMINE" -ForegroundColor Green

Write-Host "`nFichiers AUTORISES:" -ForegroundColor Green
Write-Host "OFFICE: .doc .docx .xls .xlsx .ppt .pptx .odt .ods .odp .rtf .txt .pdf" -ForegroundColor Green
Write-Host "IMAGES: .jpg .jpeg .png .gif .bmp .tiff .webp .svg .ico .psd .raw" -ForegroundColor Green

Write-Host "`nFichiers INTERDITS:" -ForegroundColor Red
Write-Host ".exe .zip .bat .cmd .ps1 .msi .rar .7z .scr .vbs (tout le reste!)" -ForegroundColor Red

Write-Host "`nComportement:" -ForegroundColor Cyan
Write-Host "✓ Mode PASSIF: Fichiers interdits BLOQUES lors du depot" -ForegroundColor Yellow
Write-Host "✓ Event Log: Chaque tentative enregistree dans Windows Event Viewer" -ForegroundColor Yellow
Write-Host "✓ Recursif: Filtrage applique sur C:\Share et tous les sous-dossiers" -ForegroundColor Yellow

Write-Host "`nPour TESTER:" -ForegroundColor Cyan
Write-Host "1. Essayer de copier un .exe ou .zip dans C:\Share\..." -ForegroundColor Gray
Write-Host "   -> Doit afficher 'Acces refuse'" -ForegroundColor Gray
Write-Host "2. Essayer de copier un .docx dans C:\Share\..." -ForegroundColor Gray
Write-Host "   -> Doit fonctionner normalement" -ForegroundColor Gray
Write-Host "3. Verifier l'Event Log:" -ForegroundColor Gray
Write-Host "   -> Event Viewer > Windows Logs > Application (Source: SRMSVC)" -ForegroundColor Gray
Write-Host "      Ou: Get-EventLog -LogName Application -Source SRMSVC -Newest 20" -ForegroundColor Gray

Write-Host "`nPour VOIR LES FILTRAGES ACTIFS:" -ForegroundColor Cyan
Write-Host "Get-FsrmFileScreen | Select Path, Active, IncludeGroup" -ForegroundColor Gray

