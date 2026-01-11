Write-Host "`n[2/4] Configuration DHCP pour VLANs..." -ForegroundColor Yellow

$DHCPScopes = @(
#Agence 9
    @{ Name = "VLAN10-Informatique";       Start = "172.28.10.3"; End = "172.28.10.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN15-Commerciaux";          Start = "172.28.15.3"; End = "172.28.15.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN20-Technique";          Start = "172.28.20.3"; End = "172.28.20.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN25-Finances";  Start = "172.28.25.3"; End = "172.28.25.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN30-Marketing";   Start = "172.28.30.3"; End = "172.28.30.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN35-R&D";        Start = "172.28.35.3"; End = "172.28.35.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN40-RH";        Start = "172.28.40.3"; End = "172.28.40.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN45-Direction";        Start = "172.28.45.3"; End = "172.28.45.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN50-Gestion";        Start = "172.28.50.3"; End = "172.28.50.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN55-Transit";        Start = "172.28.55.3"; End = "172.28.55.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN60-Serveurs";        Start = "172.28.60.3"; End = "172.28.60.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN65-VoIP";        Start = "172.28.65.3"; End = "172.28.65.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN100-Natif";        Start = "172.28.100.3"; End = "172.28.100.253"; Subnet = "255.255.255.0" },
    @{ Name = "VLAN199-Poubelle";        Start = "172.28.199.3"; End = "172.28.199.253"; Subnet = "255.255.255.0" },
#Agence 6
    @{ Name = "AG006-VLAN10-Informatique";       Start = "172.25.10.3"; End = "172.25.10.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN15-Commerciaux";          Start = "172.25.15.3"; End = "172.25.15.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN20-Technique";          Start = "172.25.20.3"; End = "172.25.20.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN25-Finances";  Start = "172.25.25.3"; End = "172.25.25.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN30-Marketing";   Start = "172.25.30.3"; End = "172.25.30.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN35-R&D";        Start = "172.25.35.3"; End = "172.25.35.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN40-RH";        Start = "172.25.40.3"; End = "172.25.40.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN45-Direction";        Start = "172.25.45.3"; End = "172.25.45.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN50-Gestion";        Start = "172.25.50.3"; End = "172.25.50.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN55-Transit";        Start = "172.25.55.3"; End = "172.25.55.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN60-Serveurs";        Start = "172.25.60.3"; End = "172.25.60.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN65-VoIP";        Start = "172.25.65.3"; End = "172.25.65.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN100-Natif";        Start = "172.25.100.3"; End = "172.25.100.253"; Subnet = "255.255.255.0" },
    @{ Name = "AG006-VLAN199-Poubelle";        Start = "172.25.199.3"; End = "172.25.199.253"; Subnet = "255.255.255.0" }
)

foreach ($Scope in $DHCPScopes) {
    try {
        Add-DhcpServerv4Scope -Name $Scope.Name -StartRange $Scope.Start -EndRange $Scope.End -SubnetMask $Scope.Subnet -LeaseDuration ([TimeSpan]::FromHours(8)) -State Active -ErrorAction SilentlyContinue
        Write-Host "OK: Scope cree: $($Scope.Name)" -ForegroundColor Green
    } catch {
        Write-Host "ATTENTION: Scope existant: $($Scope.Name)" -ForegroundColor Gray
    }
}


# SCRIPT DHCP FINALISATION (A executer APRES le redémarrage du DC)
# PowerShell 5.1 COMPATIBLE

Write-Host "FINALISATION CONFIG DHCP POST-REDEMARRAGE" -ForegroundColor Cyan

# --- [1] Attendre que DHCP soit pleinement opérationnel ---
Write-Host "`n[1/3] Attente du demarrage des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Get-Service DHCP | Start-Service -ErrorAction SilentlyContinue

# --- [2] Autoriser le serveur DHCP dans AD ---
Write-Host "`n[2/3] Autorisation du serveur DHCP dans Active Directory..." -ForegroundColor Yellow

try {
    Add-DhcpServerInDC -DnsName "DC.Belgique.lan" -IPAddress "172.28.60.21" -ErrorAction SilentlyContinue
    Write-Host "OK: Serveur DHCP autorisé dans AD" -ForegroundColor Green
} catch {
    Write-Host "ATTENTION: DHCP déjà autorisé ou erreur: $_" -ForegroundColor Gray
}

# --- [3] Configuration options DHCP pour chaque scope ---
Write-Host "`n[3/3] Configuration des options DHCP (DNS, Gateway, etc)..." -ForegroundColor Yellow

$DHCPScopes = @(
#agence 9
    @{ Name = "VLAN10-Informatique";       Gateway = "172.28.10.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN15-Commerciaux";          Gateway = "172.28.15.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN20-Technique";          Gateway = "172.28.20.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN25-Finances";  Gateway = "172.28.25.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN30-Marketing";   Gateway = "172.28.30.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN35-R&D";        Gateway = "172.28.35.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN40-RH";        Gateway = "172.28.40.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN45-Direction";        Gateway = "172.28.45.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN50-Gestion";        Gateway = "172.28.50.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN55-Transit";        Gateway = "172.28.55.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN60-Serveurs";        Gateway = "172.28.60.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN65-VoIP";        Gateway = "172.28.65.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN100-Natif";        Gateway = "172.28.100.1";    DNS = "172.28.60.21" },
    @{ Name = "VLAN199-Poubelle";        Gateway = "172.28.199.1";    DNS = "172.28.60.21" },
#agence 6
    @{ Name = "AG006-VLAN10-Informatique";       Gateway = "172.25.10.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN15-Commerciaux";          Gateway = "172.25.15.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN20-Technique";          Gateway = "172.25.20.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN25-Finances";  Gateway = "172.25.25.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN30-Marketing";   Gateway = "172.25.30.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN35-R&D";        Gateway = "172.25.35.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN40-RH";        Gateway = "172.25.40.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN45-Direction";        Gateway = "172.25.45.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN50-Gestion";        Gateway = "172.25.50.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN55-Transit";        Gateway = "172.25.55.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN60-Serveurs";        Gateway = "172.25.60.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN65-VoIP";        Gateway = "172.25.65.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN100-Natif";        Gateway = "172.25.100.1";    DNS = "172.28.60.21" },
    @{ Name = "AG006-VLAN199-Poubelle";        Gateway = "172.25.199.1";    DNS = "172.28.60.21" }
)

foreach ($Scope in $DHCPScopes) {
    $ScopeID = $Scope.Name -replace "VLAN\d+-", ""
    $ScopeFilter = "Name -eq '$($Scope.Name)'"
    $ScopeObj = Get-DhcpServerv4Scope -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $Scope.Name }
    
    if ($ScopeObj) {
        try {
            # Option 3: Default Gateway
            Set-DhcpServerv4OptionValue -ScopeId $ScopeObj.ScopeId -OptionId 3 -Value $Scope.Gateway -ErrorAction SilentlyContinue
            
            # Option 6: DNS Servers
            Set-DhcpServerv4OptionValue -ScopeId $ScopeObj.ScopeId -OptionId 6 -Value $Scope.DNS -ErrorAction SilentlyContinue
            
            # Option 15: Domain Name
            Set-DhcpServerv4OptionValue -ScopeId $ScopeObj.ScopeId -OptionId 15 -Value "Belgique.lan" -ErrorAction SilentlyContinue
            
            Write-Host "OK: Options configurees pour $($Scope.Name)" -ForegroundColor Green
        } catch {
            Write-Host "ERREUR options $($Scope.Name): $_" -ForegroundColor Red
        }
    } else {
        Write-Host "WARNING: Scope $($Scope.Name) non trouvé" -ForegroundColor Yellow
    }
}

# === [2b] Exclusions DHCP VLAN60 ===
Write-Host "`n[2b] Configuration des exclusions DHCP..." -ForegroundColor Yellow

try {
    $Scope60 = Get-DhcpServerv4Scope | Where-Object { $_.Name -eq "VLAN60-Serveurs" }

    if ($Scope60) {
        Add-DhcpServerv4ExclusionRange -ScopeId $Scope60.ScopeId -StartRange 172.28.60.21 -EndRange 172.28.60.21 -ErrorAction SilentlyContinue
        Add-DhcpServerv4ExclusionRange -ScopeId $Scope60.ScopeId -StartRange 172.28.60.100 -EndRange 172.28.60.100 -ErrorAction SilentlyContinue
        Write-Host "OK: Exclusions ajoutees au VLAN60 (.21 et .100)" -ForegroundColor Green
    } else {
        Write-Host "WARNING: VLAN60-Serveurs introuvable, exclusions non ajoutees" -ForegroundColor Red
    }
} catch {
    Write-Host "ERREUR exclusions DHCP VLAN60: $_" -ForegroundColor Red
}

Write-Host "DHCP FINALISE ET OPERATIONNEL" -ForegroundColor Green
