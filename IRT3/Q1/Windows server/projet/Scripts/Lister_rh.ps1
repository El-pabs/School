

#Requires -Version 5.1

Import-Module ActiveDirectory


$ErrorActionPreference = "Continue"
$VerbosePreference = "SilentlyContinue"

$ouRH = "OU=Ressources humaines,DC=Belgique,DC=lan"

$allUsers = @()
$totalCount = 0
$successCount = 0
$errorCount = 0
$timestampLog = Get-Date -Format "yyyy-MM-dd_HHmmss"
$logPath = "C:\Logs\RH-Users_$timestampLog.log"


function Write-LogEntry {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    Write-Host $logMessage
    Add-Content -Path $logPath -Value $logMessage -ErrorAction SilentlyContinue
}

function Get-RHUsersFromOU {
    param(
        [string]$OUPath
    )
    
    $users = @()
    
    try {
        # Vérification que l'UO existe
        $ou = Get-ADOrganizationalUnit -Identity $OUPath -ErrorAction Stop
        Write-LogEntry "✓ UO trouvée : $($ou.Name)" "SUCCESS"
        
        # Récupération de tous les utilisateurs de l'UO et ses sous-OUs
        $adUsers = Get-ADUser -Filter "*" -SearchBase $OUPath -SearchScope Subtree `
            -Properties DisplayName, SamAccountName, EmailAddress, `
            DistinguishedName, Enabled, LastLogonDate, Department, Description, Office, Manager `
            -ErrorAction Stop
        
        if ($adUsers) {
            $userCount = @($adUsers).Count
            Write-LogEntry "Total utilisateurs trouvés dans l'UO : $userCount" "INFO"
            
            foreach ($user in $adUsers) {
                try {
                    $userInfo = [PSCustomObject]@{
                        DisplayName       = $user.DisplayName
                        SamAccountName    = $user.SamAccountName
                        EmailAddress      = $user.EmailAddress
                        DistinguishedName = $user.DistinguishedName
                        Department        = $user.Department
                        Description       = $user.Description
                        Office            = $user.Office
                        Manager           = $user.Manager
                        Enabled           = $user.Enabled
                        LastLogonDate     = $user.LastLogonDate
                        OUPath            = $OUPath
                    }
                    
                    $users += $userInfo
                    
                    $status = if($user.Enabled){'Actif'}else{'Inactif'}
                    Write-LogEntry "  ✓ $($user.DisplayName) ($($user.SamAccountName)) - $($user.Description) - [$status]" "INFO"
                    $script:successCount++
                }
                catch {
                    Write-LogEntry "  ✗ Erreur lors du traitement de $($user.SamAccountName) : $_" "ERROR"
                    $script:errorCount++
                }
            }
        }
        else {
            Write-LogEntry "  ⚠ Aucun utilisateur trouvé dans l'UO" "WARNING"
        }
    }
    catch {
        Write-LogEntry "✗ Erreur : L'UO '$OUPath' n'existe pas ou n'est pas accessible" "ERROR"
        Write-LogEntry "  Détail : $_" "ERROR"
        Write-LogEntry "  Conseil : Vérifiez le DN de l'UO avec : Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName" "INFO"
        $script:errorCount++
    }
    
    return $users
}

function Find-RHOrganizationalUnit {
    Write-LogEntry "Recherche automatique de l'UO RH..." "INFO"
    Write-Host ""
    
    try {
        # Rechercher toutes les OUs contenant "RH" ou "Ressources"
        $ous = Get-ADOrganizationalUnit -Filter "Name -like '*RH*' -or Name -like '*Ressources*'" `
            -SearchBase "DC=Belgique,DC=lan" -SearchScope Subtree -ErrorAction Stop
        
        if ($ous) {
            Write-LogEntry "OUs trouvées correspondant à 'RH' ou 'Ressources' :" "INFO"
            $ous | ForEach-Object {
                Write-LogEntry "  - $($_.Name) : $($_.DistinguishedName)" "INFO"
            }
            return $ous[0].DistinguishedName
        }
        else {
            Write-LogEntry "Aucune OU trouvée avec 'RH' ou 'Ressources'" "WARNING"
        }
    }
    catch {
        Write-LogEntry "Erreur lors de la recherche : $_" "ERROR"
    }
    
    return $null
}

Write-Host ""
Write-LogEntry "DEBUT : Liste des utilisateurs RH depuis Active Directory" "INFO"
Write-LogEntry "Domaine : Belgique.lan" "INFO"
Write-Host ""

# Création du répertoire de logs s'il n'existe pas
if (-not (Test-Path "C:\Logs")) {
    New-Item -ItemType Directory -Path "C:\Logs" -Force -ErrorAction SilentlyContinue | Out-Null
}

# Vérifier si l'UO existe
$testOU = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouRH'" -ErrorAction SilentlyContinue

if (-not $testOU) {
    Write-LogEntry "⚠ L'UO spécifiée n'a pas été trouvée" "WARNING"
    Write-Host ""
    
    # Recherche automatique
    $foundOU = Find-RHOrganizationalUnit
    
    if ($foundOU) {
        Write-Host ""
        Write-LogEntry "Utilisation de l'UO trouvée : $foundOU" "SUCCESS"
        $ouRH = $foundOU
    }
    else {
        Write-Host ""
        Write-LogEntry "ERREUR : Impossible de trouver l'UO RH. Exécution annulée." "ERROR"
        Write-Host ""
        Write-LogEntry "Actions suggérées :" "INFO"
        Write-LogEntry "  1. Exécuter cette commande pour afficher toutes les OUs :" "INFO"
        Write-LogEntry "     Get-ADOrganizationalUnit -Filter * -SearchBase 'DC=Belgique,DC=lan' | Select-Object Name, DistinguishedName" "INFO"
        Write-LogEntry "  2. Adapter le DN dans le script (variable \$ouRH)" "INFO"
        Write-LogEntry "" "INFO"
        exit 1
    }
}

Write-LogEntry "Traitement de l'UO RH : $ouRH" "INFO"
Write-Host ""

$usersFromOU = Get-RHUsersFromOU -OUPath $ouRH

if ($usersFromOU) {
    $allUsers = $usersFromOU
    $script:totalCount = @($usersFromOU).Count
}


Write-Host ""
Write-LogEntry "RAPPORT FINAL" "INFO"

Write-LogEntry "Total général : $totalCount utilisateur(s) RH" "INFO"
Write-LogEntry "Utilisateurs traités avec succès : $successCount" "SUCCESS"
Write-LogEntry "Erreurs rencontrées : $errorCount" $(if ($errorCount -gt 0) { "WARNING" } else { "INFO" })

# Export en CSV
if ($allUsers.Count -gt 0) {
    $csvPath = "C:\Logs\RH-Users_Export_$timestampLog.csv"
    $allUsers | Export-Csv -Path $csvPath -Encoding UTF8 -NoTypeInformation -Delimiter ";" -ErrorAction SilentlyContinue
    Write-LogEntry "✓ Export CSV : $csvPath" "SUCCESS"
    Write-Host ""
    Write-Host "Aperçu de l'export :" -ForegroundColor Cyan
    $allUsers | Format-Table -Property DisplayName, SamAccountName, Description, Office -AutoSize | Out-Host
}
else {
    Write-LogEntry "Aucun utilisateur à exporter" "WARNING"
}

# Affichage du chemin du log
Write-Host ""
Write-LogEntry "Fichier log : $logPath" "INFO"

Write-Host ""
Write-LogEntry "FIN DU SCRIPT" "INFO"
Write-Host ""

exit $errorCount

# SIG # Begin signature block
# MIIIfwYJKoZIhvcNAQcCoIIIcDCCCGwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+3xr8APJIgvKw3SrbAealiVc
# 2IigggXnMIIF4zCCBMugAwIBAgITJgAAAAJY1JnhnvnHpgAAAAAAAjANBgkqhkiG
# 9w0BAQsFADBKMRMwEQYKCZImiZPyLGQBGRYDbGFuMRgwFgYKCZImiZPyLGQBGRYI
# QmVsZ2lxdWUxGTAXBgNVBAMTEEJlbGdpcXVlLVJvb3QtQ0EwHhcNMjUxMjA4MDk0
# NjE5WhcNMjYxMjA4MDk0NjE5WjBXMRMwEQYKCZImiZPyLGQBGRYDbGFuMRgwFgYK
# CZImiZPyLGQBGRYIQmVsZ2lxdWUxDjAMBgNVBAMTBVVzZXJzMRYwFAYDVQQDEw1B
# ZG1pbmlzdHJhdG9yMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7Ei1
# NXmmjyBEq7v0g7Hrc9pn/cDYxw1NKAFNtniWfcfzT6ok36+WLskEOZ6yvTAWKXCX
# fCWR5aUTHZj0JSVpAMXQMxoLF4rQFbTmBMwCgypdmcycgG003Ap1k9BlH+L3vDrb
# x3rjXgduqt1BpRI2uK5/aRpCcfPEY7JjLJ49kh5Eqti9m7U8g5KIM1N4825qaobZ
# tfJ7ftvtc68WY64afffLkHsialOAMpXeouu6lHWCZVHyznGddYOt/du2mnNdpGBG
# jHZltzZkEIsHf72GkHsafiRxv1hIRujJNk24RrZyw0ObwGOIx2BkLvGOCSg6svPs
# SI2drpA7V4TuhLZgfQIDAQABo4ICszCCAq8wJQYJKwYBBAGCNxQCBBgeFgBDAG8A
# ZABlAFMAaQBnAG4AaQBuAGcwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/
# BAQDAgeAMB0GA1UdDgQWBBR8tbOpIQ3Hc3HRnhRV0ChrrwiFPTAfBgNVHSMEGDAW
# gBSgDUHa3IFWQ1EIFbV8IByBTWv+hDCB1AYDVR0fBIHMMIHJMIHGoIHDoIHAhoG9
# bGRhcDovLy9DTj1CZWxnaXF1ZS1Sb290LUNBLENOPURDLUJSVVhFTExFUyxDTj1D
# RFAsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29u
# ZmlndXJhdGlvbixEQz1CZWxnaXF1ZSxEQz1sYW4/Y2VydGlmaWNhdGVSZXZvY2F0
# aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIHD
# BggrBgEFBQcBAQSBtjCBszCBsAYIKwYBBQUHMAKGgaNsZGFwOi8vL0NOPUJlbGdp
# cXVlLVJvb3QtQ0EsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENO
# PVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9QmVsZ2lxdWUsREM9bGFuP2NB
# Q2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9y
# aXR5MDUGA1UdEQQuMCygKgYKKwYBBAGCNxQCA6AcDBpBZG1pbmlzdHJhdG9yQEJl
# bGdpcXVlLmxhbjBNBgkrBgEEAYI3GQIEQDA+oDwGCisGAQQBgjcZAgGgLgQsUy0x
# LTUtMjEtMTA4OTI0MTc0LTQwMzMwMjg3NjgtMTE0NjcxNjgzNi01MDAwDQYJKoZI
# hvcNAQELBQADggEBAA5qenVCPtVIOYMlWsDXN6lsMbzgr4Xhh4anuqP8NVQvbZOU
# SUKX+NkhLQW2hdumeDZOAv6k5ANwgaivlKLwNtzLFg1HU956PFGMWKLJYcr62nws
# TLits7iW3jy2kTAt2DyCgVQmUBitnM4Ry1cl/QnXoqYG4iiMRp8xGKfDsdczKYl9
# 1LQ64gItRBlC3gkKQHhqedwDdnaUr7uoyo0bnwZdKiYwsciFF1jvyHWMh2HOH5PG
# /HUnDwbSBiYfZnlqP1o7SxgW2g8Sopv/zgmvpBqNhUeEx6c33g4bgcLkhMkKa4Wd
# HFEAHLgwaOugVf9V5HaKxjb7sWfPJQZEU5QHzs0xggICMIIB/gIBATBhMEoxEzAR
# BgoJkiaJk/IsZAEZFgNsYW4xGDAWBgoJkiaJk/IsZAEZFghCZWxnaXF1ZTEZMBcG
# A1UEAxMQQmVsZ2lxdWUtUm9vdC1DQQITJgAAAAJY1JnhnvnHpgAAAAAAAjAJBgUr
# DgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
# hkiG9w0BCQQxFgQUBtIgXOfMCUa+QEx84cWSZdv+JuYwDQYJKoZIhvcNAQEBBQAE
# ggEAfQPB2gCetZ0ui7BmurXwNjNHS7qbPwgMothnMUWAkbscBEkUcy0mgxdNiHcS
# eSNXHJDASgMoQ786zE0yU1xyTGFnN5GTU0KJ1i1c9NApuuB0o6y4gg/0uF8+E4xx
# 5GLBoqQLy0RU/0v9yE4Qoi5fRcpW7BO35TKH8WfRfD67mYN/6Rda3DNb0wQl4E+Z
# MolHr24nkBpwCxVfPDHonHR14PiML9idql8lRackhmQ0HpHE7+BFy/yBJX7mVNoG
# oONkJ6KYEZr2XeD0OvbDk8f2/8EW0noYgVNEKPKJSxvyKLk0N1gWupMOlR2YEkra
# Y16OL/Ce8lm73gNUh0GlIjna9Q==
# SIG # End signature block
