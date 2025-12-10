# SCRIPT 00 : NETTOYAGE COMPLET - Suppression OUs + Utilisateurs
# Fichier: 00-Cleanup-COMPLETE.ps1
# PowerShell 5.1 COMPATIBLE
# ⚠️ ATTENTION: Ce script SUPPRIME TOUS les utilisateurs et OUs ! 

Write-Host "========================================" -ForegroundColor Red
Write-Host "SUPPRESSION COMPLETE DU DOMAINE" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""
Write-Host "ATTENTION: Vous allez supprimer :" -ForegroundColor Yellow
Write-Host "  - Tous les utilisateurs" -ForegroundColor Yellow
Write-Host "  - Toutes les OUs" -ForegroundColor Yellow
Write-Host "  - Cette action est IRREVERSIBLE" -ForegroundColor Red
Write-Host ""

$Confirm = Read-Host "Tapez 'OUI' pour confirmer la suppression"
if ($Confirm -ne "OUI") {
    Write-Host "Opération annulée." -ForegroundColor Green
    Exit
}

# --- [1] Suppression des utilisateurs ---
Write-Host "`n[1/4] Suppression des utilisateurs..." -ForegroundColor Yellow

$Users = Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase "DC=Belgique,DC=lan" -ErrorAction SilentlyContinue | `
    Where-Object { $_.SamAccountName -notmatch "^(Administrator|Guest|krbtgt|IUSR|IWAM)" }

$DeletedCount = 0
foreach ($User in $Users) {
    try {
        Remove-ADUser -Identity $User.ObjectGUID -Confirm:$false -ErrorAction Stop
        Write-Host "SUPPRIME: $($User.SamAccountName)" -ForegroundColor Green
        $DeletedCount++
    } catch {
        Write-Host "ERREUR suppression $($User.SamAccountName): $_" -ForegroundColor Red
    }
}

Write-Host "OK: $DeletedCount utilisateurs supprimés" -ForegroundColor Green

# --- [1.5] Desactivation de la protection recursively ---
Write-Host "`n[2/4] Desactivation de la protection recursively..." -ForegroundColor Yellow

$RootOU = "OU=Color,DC=Belgique,DC=lan"
$AllOUs = Get-ADOrganizationalUnit -Filter * -SearchBase $RootOU -SearchScope Subtree -ErrorAction SilentlyContinue

$ProtectionCount = 0
foreach ($OU in $AllOUs) {
    if ($OU.ProtectedFromAccidentalDeletion) {
        Set-ADOrganizationalUnit -Identity $OU -ProtectedFromAccidentalDeletion $false -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "Protection desactivee: $($OU.Name)" -ForegroundColor Cyan
        $ProtectionCount++
    }
}

Write-Host "OK: $ProtectionCount OUs deverouillees" -ForegroundColor Green

# --- [2] Vidage des OUs ---
Write-Host "`n[3/4] Vidage des OUs..." -ForegroundColor Yellow

$OUsToDelete = @(
    # OUs Sous-départements (niveau 2) - SUPPRESSION D'ABORD
    "OU=Site4,OU=Marketting,DC=Belgique,DC=lan",
    "OU=Site3,OU=Marketting,DC=Belgique,DC=lan",
    "OU=Site2,OU=Marketting,DC=Belgique,DC=lan",
    "OU=Site1,OU=Marketting,DC=Belgique,DC=lan",
    "OU=Technico,OU=Commerciaux,DC=Belgique,DC=lan",
    "OU=Sédentaires,OU=Commerciaux,DC=Belgique,DC=lan",
    "OU=Testing,OU=R&D,DC=Belgique,DC=lan",
    "OU=Recherche,OU=R&D,DC=Belgique,DC=lan",
    "OU=Recrutement,OU=Ressources humaines,DC=Belgique,DC=lan",
    "OU=Gestion du personnel,OU=Ressources humaines,DC=Belgique,DC=lan",
    "OU=Systèmes,OU=Informatique,DC=Belgique,DC=lan",
    "OU=HotLine,OU=Informatique,DC=Belgique,DC=lan",
    "OU=Développement,OU=Informatique,DC=Belgique,DC=lan",
    "OU=Investissements,OU=Finances,DC=Belgique,DC=lan",
    "OU=Comptabilité,OU=Finances,DC=Belgique,DC=lan",
    "OU=Techniciens,OU=Technique,DC=Belgique,DC=lan",
    "OU=Achat,OU=Technique,DC=Belgique,DC=lan",
    
    # OUs Catégories (niveau 1) - EN DERNIER
    "OU=Direction,DC=Belgique,DC=lan",
    "OU=Marketting,DC=Belgique,DC=lan",
    "OU=Commerciaux,DC=Belgique,DC=lan",
    "OU=R&D,DC=Belgique,DC=lan",
    "OU=Ressources humaines,DC=Belgique,DC=lan",
    "OU=Informatique,DC=Belgique,DC=lan",
    "OU=Finances,DC=Belgique,DC=lan",
    "OU=Technique,DC=Belgique,DC=lan"
)

foreach ($OUPath in $OUsToDelete) {
    try {
        $OU = Get-ADOrganizationalUnit -Identity $OUPath -ErrorAction SilentlyContinue
        if ($OU) {
            # Récupérer tous les objets dans l'OU (users, computers, etc)
            $Objects = Get-ADObject -Filter * -SearchBase $OUPath -SearchScope OneLevel -ErrorAction SilentlyContinue
            
            foreach ($Object in $Objects) {
                Remove-ADObject -Identity $Object.ObjectGUID -Confirm:$false -ErrorAction SilentlyContinue
            }
            
            if ($Objects.Count -gt 0) {
                Write-Host "Vide: $($OU.Name) ($($Objects.Count) objets supprimés)" -ForegroundColor Cyan
            }
        }
    } catch {
        # Ignorer les erreurs, on vide juste ce qu'on peut
    }
}

# --- [3] Suppression de l'OU racine Color ---
Write-Host "`n[3.5/4] Suppression de l'OU racine..." -ForegroundColor Yellow

$RootOU = "OU=Color,DC=Belgique,DC=lan"
$RootOUObj = Get-ADOrganizationalUnit -Identity $RootOU -ErrorAction SilentlyContinue
if ($RootOUObj) {
    # Vider l'OU racine
    $RootObjects = Get-ADObject -Filter * -SearchBase $RootOU -SearchScope OneLevel -ErrorAction SilentlyContinue
    foreach ($RootObj in $RootObjects) {
        Remove-ADObject -Identity $RootObj.ObjectGUID -Confirm:$false -ErrorAction SilentlyContinue
    }
}

# Ajouter à la liste de suppression
$OUsToDelete += $RootOU

# --- [4] Suppression des OUs ---
Write-Host "`n[4/4] Suppression des OUs..." -ForegroundColor Yellow

$DeletedOUCount = 0
foreach ($OUPath in $OUsToDelete) {
    try {
        $OU = Get-ADOrganizationalUnit -Identity $OUPath -ErrorAction SilentlyContinue
        
        if ($OU) {
            # Supprimer l'OU
            Remove-ADOrganizationalUnit -Identity $OUPath -Confirm:$false -ErrorAction Stop
            Write-Host "SUPPRIMEE: $($OU.Name)" -ForegroundColor Green
            $DeletedOUCount++
        }
    } catch {
        Write-Host "ERREUR suppression OU ${OUPath}: $_" -ForegroundColor Red
    }
}

Write-Host "OK: $DeletedOUCount OUs supprimées" -ForegroundColor Green

# --- Résumé ---
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "SUPPRESSION TERMINEE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Utilisateurs supprimés: $DeletedCount" -ForegroundColor Cyan
Write-Host "OUs deverouillees: $ProtectionCount" -ForegroundColor Cyan
Write-Host "OUs supprimées: $DeletedOUCount" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour recréer la structure, lancez le script 02-CreationOUs.ps1" -ForegroundColor Yellow
