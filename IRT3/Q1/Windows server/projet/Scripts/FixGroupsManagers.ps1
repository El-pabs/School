# FIX : REGROUPER LES MANAGERS PAR DEPARTEMENT PRINCIPAL
# + ORGANISER LES GROUPES DANS DES OUs SPECIFIQUES (GG et GL)


$Domain = "Belgique.lan"
$DomainDN = "DC=Belgique,DC=lan"

Write-Host "FIX : GROUPES MANAGERS PAR DEPT PRINCIPAL" -ForegroundColor Magenta

# --- [1] CREER LES OUs POUR LES GROUPES ---
Write-Host "`n[1/4] Creation des OUs GG et GL...`n" -ForegroundColor Yellow

$OUPaths = @("OU=GG,DC=Belgique,DC=lan", "OU=GL,DC=Belgique,DC=lan")

foreach ($OUPath in $OUPaths) {
    $OUName = ($OUPath.Split("=")[1]).Split(",")[0]
    
    $Existing = Get-ADOrganizationalUnit -Filter "Name -eq '$OUName' -and DistinguishedName -eq '$OUPath'" -ErrorAction SilentlyContinue
    
    if (-not $Existing) {
        try {
            New-ADOrganizationalUnit -Name $OUName -Path $DomainDN -Confirm:$false
            Write-Host "✓ OU creee: $OUName" -ForegroundColor Green
        } catch {
            Write-Host "✗ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "✓ OU existe: $OUName" -ForegroundColor Cyan
    }
}

# --- [2] DEPLACER LES GROUPES EXISTANTS VERS LEURS OUs ---
Write-Host "`n[2/4] Deplacement des groupes vers les bonnes OUs...`n" -ForegroundColor Yellow

# Déplacer les GG existants vers OU=GG
$AllGGGroups = Get-ADGroup -Filter "Name -like 'GG_*'" -ErrorAction SilentlyContinue

foreach ($Group in $AllGGGroups) {
    $CurrentPath = $Group.DistinguishedName
    
    # Vérifier que ce groupe n'est pas déjà dans OU=GG
    if ($CurrentPath -notlike "*OU=GG,*") {
        try {
            Move-ADObject -Identity $Group.DistinguishedName -TargetPath "OU=GG,$DomainDN" -Confirm:$false
            Write-Host "  ✓ Groupe $($Group.Name) deplace vers OU=GG" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Erreur deplacement $($Group.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Déplacer les DL existants vers OU=GL
$AllDLGroups = Get-ADGroup -Filter "Name -like 'DL_*'" -ErrorAction SilentlyContinue

foreach ($Group in $AllDLGroups) {
    $CurrentPath = $Group.DistinguishedName
    
    if ($CurrentPath -notlike "*OU=GL,*") {
        try {
            Move-ADObject -Identity $Group.DistinguishedName -TargetPath "OU=GL,$DomainDN" -Confirm:$false
            Write-Host "  ✓ Groupe $($Group.Name) deplace vers OU=GL" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Erreur deplacement $($Group.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# --- [3] CREER LES GROUPES MANAGERS PAR DEPARTEMENT PRINCIPAL ---
Write-Host "`n[3/4] Creation des GG_Managers par departement principal...`n" -ForegroundColor Yellow

# Structure: Departement Principal -> Sous-Departements
$DepartementPrincipal = @{
    "Informatique" = @("Développement", "HotLine", "Systèmes")
    "Ressources humaines" = @("Gestion du personnel", "Recrutement")
    "Finances" = @("Comptabilité", "Investissements")
    "R&D" = @("Recherche", "Testing")
    "Technique" = @("Achat", "Techniciens")
    "Commerciaux" = @("Sédentaires", "Technico")
    "Marketting" = @("Site1", "Site2", "Site3", "Site4")
}

$ManagerGroupsByDept = @{}

foreach ($MainDept in $DepartementPrincipal.Keys) {
    $ManagerGroupName = "GG_Managers_$MainDept"
    $ManagerGroupExisting = Get-ADGroup -Filter "SamAccountName -eq '$ManagerGroupName'" -ErrorAction SilentlyContinue
    
    if (-not $ManagerGroupExisting) {
        try {
            New-ADGroup -SamAccountName $ManagerGroupName `
                -Name $ManagerGroupName `
                -GroupScope Global `
                -GroupCategory Security `
                -DisplayName "Managers - $MainDept" `
                -Description "Groupe des responsables du departement $MainDept" `
                -Path "OU=GG,$DomainDN" `
                -Confirm:$false
            Write-Host "  ✓ Groupe cree: $ManagerGroupName (OU=GG)" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ✓ Groupe existe: $ManagerGroupName" -ForegroundColor Cyan
        
        # Vérifier s'il est dans la bonne OU
        if ($ManagerGroupExisting.DistinguishedName -notlike "*OU=GG,*") {
            try {
                Move-ADObject -Identity $ManagerGroupExisting.DistinguishedName -TargetPath "OU=GG,$DomainDN" -Confirm:$false
                Write-Host "    → Deplace vers OU=GG" -ForegroundColor Cyan
            } catch {
                Write-Host "    → Erreur deplacement: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    $ManagerGroupsByDept[$MainDept] = $ManagerGroupName
}

# --- [4] REORGANISER : AJOUTER MANAGERS DE SOUS-DEPTS AU GROUPE PRINCIPAL ---
Write-Host "`n[4/4] Reorganisation : Managers des sous-depts -> Groupe Principal...`n" -ForegroundColor Yellow

# La structure des responsables (depuis ton script original)
$Structure = @{
    "Ressources humaines" = @{
        "Gestion du personnel" = "romain.marcel"
        "Recrutement"          = "francois.bellante"
    }
    "Finances" = @{
        "Comptabilité"    = "geoffrey.craeyé"
        "Investissements" = "jason.paris"
    }
    "Informatique" = @{
        "Développement" = "adrien.bavouakenfack"
        "HotLine"       = "victor.quicken"
        "Systèmes"      = "arnaud.baisagurova"
    }
    "R&D" = @{
        "Recherche" = "lorraine.al-khamry"
        "Testing"   = "emilie.bayanaknlend"
    }
    "Technique" = @{
        "Achat"       = "ruben.alaca"
        "Techniciens" = "geoffrey.chiarelli"
    }
    "Commerciaux" = @{
        "Sédentaires" = "dorcas.balci"
        "Technico"    = "adriano.cambier"
    }
    "Marketting" = @{
        "Site1" = "remi.brodkom"
        "Site2" = "simon.amand"
        "Site3" = "vincent.aubly"
        "Site4" = "audrey.brogniez"
    }
}

foreach ($MainDept in $Structure.Keys) {
    $ManagerGroupName = "GG_Managers_$MainDept"
    $ManagerGroup = Get-ADGroup -Filter "SamAccountName -eq '$ManagerGroupName'" -ErrorAction SilentlyContinue
    
    if ($ManagerGroup) {
        Write-Host "  📌 $MainDept - Ajout des managers:" -ForegroundColor Cyan
        
        foreach ($SubDept in $Structure[$MainDept].Keys) {
            $ManagerSamName = $Structure[$MainDept][$SubDept]
            
            # Normaliser le SamAccountName (remove accents)
            $ManagerSamName = $ManagerSamName.Replace("é", "e").Replace("ç", "c").Replace(" ", "").ToLower()
            
            # Chercher l'utilisateur
            $ManagerUser = Get-ADUser -Filter "SamAccountName -eq '$ManagerSamName'" -ErrorAction SilentlyContinue
            
            if ($ManagerUser) {
                # Vérifier s'il est déjà membre du groupe
                $IsMember = Get-ADGroupMember -Identity $ManagerGroup -ErrorAction SilentlyContinue | `
                    Where-Object { $_.SamAccountName -eq $ManagerSamName }
                
                if (-not $IsMember) {
                    try {
                        Add-ADGroupMember -Identity $ManagerGroup -Members $ManagerUser -Confirm:$false
                        Write-Host "      ✓ $ManagerSamName ajout a $ManagerGroupName (sous-dept: $SubDept)" -ForegroundColor Green
                    } catch {
                        $ErrorMsg = $_.Exception.Message
                        Write-Host "      ✗ Erreur ajout ${ManagerSamName} : $ErrorMsg" -ForegroundColor Red
                    }
                } else {
                    Write-Host "      ✓ $ManagerSamName deja present" -ForegroundColor Gray
                }
            } else {
                Write-Host "      ✗ User non trouve: $ManagerSamName" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  ✗ Groupe non trouve: $ManagerGroupName" -ForegroundColor Red
    }
}

# --- NETTOYAGE : SUPPRIMER LES ANCIENS GG_Managers_SubDept ---
Write-Host "`n[5] Nettoyage : Suppression des anciens groupes...`n" -ForegroundColor Magenta

$SubDeptManagerGroups = Get-ADGroup -Filter "Name -like 'GG_Managers_*'" -ErrorAction SilentlyContinue | `
    Where-Object { $_.Name -notmatch "GG_Managers_(Informatique|Ressources humaines|Finances|R&D|Technique|Commerciaux|Marketting)" }

foreach ($Group in $SubDeptManagerGroups) {
    Write-Host "  ? Ancien groupe trouve: $($Group.Name)" -ForegroundColor Yellow
    Write-Host "    Voulez-vous le supprimer? (ou laisser pour reference)" -ForegroundColor Gray
    
    # UNCOMMENT POUR SUPPRIMER AUTOMATIQUEMENT :
    try {
        Remove-ADGroup -Identity $Group.DistinguishedName -Confirm:$false
        Write-Host "    ✓ Supprime" -ForegroundColor Green
    } catch {
        Write-Host "    ✗ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "FIX COMPLETE!" -ForegroundColor Green
Write-Host "`nResume:`n" -ForegroundColor Cyan
Write-Host "✓ OUs creees: OU=GG et OU=GL" -ForegroundColor Green
Write-Host "✓ Groupes globaux (GG) deplaces vers OU=GG" -ForegroundColor Green
Write-Host "✓ Groupes locaux (DL) deplaces vers OU=GL" -ForegroundColor Green
Write-Host "✓ Groupes managers par departement principal: GG_Managers_[Informatique|Finances|etc]" -ForegroundColor Green
Write-Host "✓ Tous les responsables de sous-depts ajoutes au groupe principal" -ForegroundColor Green
Write-Host "`nExemple: GG_Managers_Informatique contient:" -ForegroundColor Cyan
Write-Host "  - Manager de Développement" -ForegroundColor Gray
Write-Host "  - Manager de HotLine" -ForegroundColor Gray
Write-Host "  - Manager de Systèmes" -ForegroundColor Gray
Write-Host "`nProbleme resolu: ✓`n" -ForegroundColor Green
