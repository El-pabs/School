Write-Host "PLANIFICATION BACKUP TASKS" -ForegroundColor Cyan

$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $IsAdmin) {
    Write-Host "ERREUR: Executer EN TANT QU'ADMINISTRATEUR" -ForegroundColor Red
    Exit 1
}

Write-Host "OK: Permissions admin confirmees" -ForegroundColor Green

$BackupScriptPath = "C:\Scripts\Script_08_Backup_LOCAL_NAS.ps1"

if (-not (Test-Path $BackupScriptPath)) {
    Write-Host "ERREUR: Script non trouve: $BackupScriptPath" -ForegroundColor Red
    Exit 1
}

Write-Host "OK: Script de backup trouve" -ForegroundColor Green

$Tasks = @(
    @{
        Name = "Backup-Daily-2AM"
        Description = "Sauvegarde quotidienne a 2h du matin"
        Trigger = "Daily"
        Time = "02:00"
    },
    @{
        Name = "Backup-Weekly-Sunday-1AM"
        Description = "Sauvegarde hebdomadaire le dimanche a 1h du matin"
        Trigger = "Weekly"
        Time = "01:00"
        DayOfWeek = "Sunday"
    }
)

Write-Host ""
Write-Host "[PHASE 1] Creation des taches planifiees..." -ForegroundColor Yellow

foreach ($Task in $Tasks) {
    Write-Host ""
    Write-Host "Creation: $($Task.Name)" -ForegroundColor Cyan
    
    try {
        $ExistingTask = Get-ScheduledTask -TaskName $Task.Name -ErrorAction SilentlyContinue
        
        if ($ExistingTask) {
            Write-Host "  - Tache existante, suppression..." -ForegroundColor Yellow
            Unregister-ScheduledTask -TaskName $Task.Name -Confirm:$false
        }
        
        $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$BackupScriptPath`"" -WorkingDirectory "C:\Backups"
        
        Write-Host "  - Action creee" -ForegroundColor Green
        
        if ($Task.Trigger -eq "Daily") {
            $Time = [DateTime]::Parse($Task.Time)
            $Trigger = New-ScheduledTaskTrigger -Daily -At $Time
            Write-Host "  - Trigger quotidien a $($Task.Time)" -ForegroundColor Green
        }
        elseif ($Task.Trigger -eq "Weekly") {
            $Time = [DateTime]::Parse($Task.Time)
            $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $Task.DayOfWeek -At $Time
            Write-Host "  - Trigger hebdomadaire ($($Task.DayOfWeek) a $($Task.Time))" -ForegroundColor Green
        }
        
        $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        
        $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable
        
        Register-ScheduledTask -TaskName $Task.Name -Description $Task.Description -Principal $Principal -Action $Action -Trigger $Trigger -Settings $Settings -Force | Out-Null
        
        Write-Host "  - Tache planifiee creee" -ForegroundColor Green
        
    } catch {
        Write-Host "  - ERREUR: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[PHASE 2] Verification des taches..." -ForegroundColor Yellow

foreach ($Task in $Tasks) {
    $ScheduledTask = Get-ScheduledTask -TaskName $Task.Name -ErrorAction SilentlyContinue
    
    if ($ScheduledTask) {
        Write-Host ""
        Write-Host "OK: $($Task.Name)" -ForegroundColor Green
        Write-Host "  Description: $($ScheduledTask.Description)"
        Write-Host "  Status: $($ScheduledTask.State)"
    }
}

Write-Host ""
Write-Host "PLANIFICATION TERMINEES" -ForegroundColor Green
Write-Host ""
Write-Host "Taches creees:" -ForegroundColor Cyan
Get-ScheduledTask -TaskName "Backup-*" | Select-Object TaskName, State | Format-Table -AutoSize
Write-Host ""
Write-Host "Commandes utiles:" -ForegroundColor Cyan
Write-Host "  Lancer une tache: Start-ScheduledTask -TaskName 'Backup-Daily-2AM'" -ForegroundColor Gray
Write-Host "  Voir les taches: Get-ScheduledTask -TaskName 'Backup-*'" -ForegroundColor Gray
Write-Host ""
