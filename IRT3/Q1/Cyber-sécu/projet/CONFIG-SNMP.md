# Configuration SNMP pour Équipements Réseau

## 📋 Guide de Configuration SNMP

Ce document explique comment activer SNMP sur tes équipements pour permettre au serveur de monitoring de récupérer les métriques (CPU, Mémoire, Sessions, etc.).

---

## 🔧 Configuration par Équipement

### 1️⃣ FortiGate AG008 (172.27.251.5)

#### Connexion SSH ou Console
```bash
ssh admin@172.27.251.5
```

#### Configuration SNMP v2c
```bash
# Activer SNMP
config system snmp sysinfo
    set status enable
    set description "FortiGate-AG008"
    set location "Site-Principal"
    set contact-info "admin@mondomaine.local"
end

# Créer la community SNMP (lecture seule)
config system snmp community
    edit 1
        set name "public"
        set query-v1-status enable
        set query-v2c-status enable
        set trap-v1-status disable
        set trap-v2c-status disable
        set events cpu-high mem-low
        config hosts
            edit 1
                set ip 172.27.50.2 255.255.255.255   # IP du serveur monitoring
            next
        end
        set status enable
    next
end
```

#### Vérification
```bash
# Afficher la configuration SNMP
get system snmp sysinfo
get system snmp community

# Tester depuis le serveur monitoring
snmpget -v2c -c public 172.27.251.5 1.3.6.1.4.1.12356.101.4.1.3.0
# Devrait retourner: la charge CPU en %
```

#### OIDs FortiGate Importants
| Métrique | OID | Description |
|----------|-----|-------------|
| CPU Usage | `1.3.6.1.4.1.12356.101.4.1.3.0` | % utilisation CPU |
| Memory Usage | `1.3.6.1.4.1.12356.101.4.1.4.0` | % utilisation mémoire |
| Sessions Actives | `1.3.6.1.4.1.12356.101.4.1.8.0` | Nombre de sessions |
| Uptime | `1.3.6.1.2.1.1.3.0` | Temps depuis démarrage |

---

### 2️⃣ Switch Cisco Core (172.27.50.70)

#### Connexion Console ou SSH
```bash
ssh admin@172.27.50.70
enable
configure terminal
```

#### Configuration SNMP v2c
```bash
# Activer SNMP
snmp-server community public RO
snmp-server location "Salle-Serveurs"
snmp-server contact "admin@mondomaine.local"

# Limiter l'accès au serveur monitoring
access-list 10 permit 172.27.50.2
snmp-server community public RO 10

# Activer les traps (optionnel)
snmp-server enable traps cpu threshold
snmp-server enable traps memory bufferpeak
snmp-server host 172.27.50.2 version 2c public

# Sauvegarder
end
write memory
```

#### Vérification
```bash
# Afficher la configuration SNMP
show snmp community
show snmp

# Tester depuis le serveur monitoring
snmpget -v2c -c public 172.27.50.70 1.3.6.1.4.1.9.9.109.1.1.1.1.5.1
# Devrait retourner: la charge CPU en %
```

#### OIDs Cisco Importants
| Métrique | OID | Description |
|----------|-----|-------------|
| CPU 5 sec | `1.3.6.1.4.1.9.9.109.1.1.1.1.5.1` | % CPU (5 secondes) |
| CPU 1 min | `1.3.6.1.4.1.9.9.109.1.1.1.1.6.1` | % CPU (1 minute) |
| Memory Used | `1.3.6.1.4.1.9.9.48.1.1.1.5.1` | Bytes utilisés |
| Memory Free | `1.3.6.1.4.1.9.9.48.1.1.1.6.1` | Bytes libres |
| Interface Status | `1.3.6.1.2.1.2.2.1.8.X` | État interface X |

---

### 3️⃣ Routeur WAN (172.27.0.1)

#### Si c'est un Routeur Cisco
```bash
ssh admin@172.27.0.1
enable
configure terminal

# Configuration identique au Switch
snmp-server community public RO
snmp-server location "DMZ-WAN"
snmp-server contact "admin@mondomaine.local"

# Limiter l'accès
access-list 10 permit 172.27.50.2
snmp-server community public RO 10

end
write memory
```

#### Si c'est un Routeur Linux/pfSense/autre
**Linux (net-snmp):**
```bash
sudo apt-get install snmpd
sudo nano /etc/snmp/snmpd.conf
```

Ajouter/modifier:
```
# Community SNMP
rocommunity public 172.27.50.2

# Emplacement et contact
syslocation "Routeur-WAN"
syscontact "admin@mondomaine.local"
```

Redémarrer:
```bash
sudo systemctl restart snmpd
sudo systemctl enable snmpd
```

#### Vérification
```bash
# Tester depuis le serveur monitoring
snmpget -v2c -c public 172.27.0.1 1.3.6.1.4.1.9.9.109.1.1.1.1.5.1
# ou pour Linux générique:
snmpget -v2c -c public 172.27.0.1 1.3.6.1.2.1.25.3.3.1.2.1
```

---

## 🧪 Tests de Validation

### Depuis le Serveur de Monitoring (172.27.50.2)

#### 1. Tester la Connectivité SNMP
```bash
# FortiGate
snmpwalk -v2c -c public 172.27.251.5 1.3.6.1.4.1.12356.101.4.1

# Switch
snmpwalk -v2c -c public 172.27.50.70 1.3.6.1.4.1.9.9.109

# Routeur
snmpwalk -v2c -c public 172.27.0.1 system
```

#### 2. Tester les OIDs Critiques
```bash
#!/bin/bash
# test-snmp.sh - Script de validation SNMP

DEVICES=(
    "172.27.251.5:FortiGate"
    "172.27.50.70:Switch"
    "172.27.0.1:Routeur"
)

for device in "${DEVICES[@]}"; do
    IFS=':' read -r ip name <<< "$device"
    echo "=== Test $name ($ip) ==="
    
    # Test CPU (FortiGate)
    if [[ "$name" == "FortiGate" ]]; then
        CPU=$(snmpget -v2c -c public -Oqv $ip 1.3.6.1.4.1.12356.101.4.1.3.0 2>/dev/null)
        echo "  CPU: ${CPU}%"
    fi
    
    # Test CPU (Cisco)
    if [[ "$name" == "Switch" ]] || [[ "$name" == "Routeur" ]]; then
        CPU=$(snmpget -v2c -c public -Oqv $ip 1.3.6.1.4.1.9.9.109.1.1.1.1.5.1 2>/dev/null)
        echo "  CPU: ${CPU}%"
    fi
    
    # Test uptime (tous)
    UPTIME=$(snmpget -v2c -c public -Oqv $ip 1.3.6.1.2.1.1.3.0 2>/dev/null)
    echo "  Uptime: $UPTIME"
    
    echo ""
done
```

Lancer:
```bash
chmod +x test-snmp.sh
./test-snmp.sh
```

---

## ⚠️ Sécurité SNMP

### Recommandations de Sécurité

1. **Utiliser des communities complexes en production**
   ```bash
   # Au lieu de "public", utiliser:
   snmp-server community "M0n1t0r!nG_S3cur3_2025" RO
   ```

2. **Limiter par ACL/Firewall**
   - Autoriser UNIQUEMENT l'IP du serveur monitoring (172.27.50.2)
   - Bloquer SNMP (UDP 161) depuis l'extérieur

3. **SNMPv3 (optionnel, plus sécurisé)**
   - Authentification + chiffrement
   - À configurer si données sensibles

4. **Logs SNMP**
   ```bash
   # FortiGate : activer les logs SNMP
   config log syslogd setting
       set status enable
   end
   ```

---

## 📊 Métriques Disponibles par Équipement

### FortiGate
- ✅ CPU Usage (%)
- ✅ Memory Usage (%)
- ✅ Sessions Actives
- ✅ Uptime
- ⚠️ Interface Traffic (nécessite OIDs supplémentaires)

### Switch Cisco
- ✅ CPU Usage (%)
- ✅ Memory Usage (%)
- ✅ Uptime
- ✅ Interface Status
- ⚠️ Interface Traffic (nécessite OIDs supplémentaires)

### Routeur
- ✅ CPU Usage (%)
- ✅ Memory Usage (%)
- ✅ Uptime
- ⚠️ Dépend du modèle

---

## 🚀 Activation du Monitoring

Une fois SNMP configuré sur tous les équipements:

```bash
# Sur le serveur de monitoring
sudo systemctl restart snmp-poller
sudo systemctl status snmp-poller

# Vérifier les logs
sudo tail -f /var/log/alerts.log | grep SNMP

# Vérifier les métriques
cat /var/lib/monitoring/metrics.json | jq '.current'
```

---

## 🆘 Dépannage

### Problème: "Timeout (No Response)"
```bash
# Vérifier firewall sur l'équipement
# FortiGate:
diagnose debug application snmp 255
diagnose sniffer packet any 'udp port 161' 4

# Cisco:
debug snmp packets
```

### Problème: "Authentication failure"
```bash
# Vérifier la community
show snmp community   # Cisco
get system snmp community   # FortiGate
```

### Problème: "OID non trouvé"
```bash
# Lister tous les OIDs disponibles
snmpwalk -v2c -c public IP_EQUIPEMENT 1.3.6
```

---

## 📞 Support

Si problème persistant:
1. Vérifier la connectivité réseau (ping)
2. Vérifier le firewall (UDP 161 autorisé)
3. Tester avec snmpwalk complet
4. Consulter les logs de l'équipement

**Bon monitoring ! 🎯**
