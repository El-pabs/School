# Solution 2 : Auto-fix SNMP Write (intégration avec snmp-poller existant)

## 🎯 Architecture
- **Ton snmp-poller.py existant** : Continue de surveiller les interfaces
- **snmp-autofix.py** : Nouveau script pour réactiver via SNMP SET
- **Modification du poller** : Appelle l'auto-fix quand interface DOWN détectée
- **Switch** : SNMP RW (Read-Write) activé

---

## 🔧 Partie 1 : Configuration du Switch (Cisco Catalyst 2960+)

### Étape 1 : Configuration SNMP Read-Write
```bash
# Connexion au switch
ssh admini@172.27.50.70
```

### Étape 2 : Ajout de la communauté RW
```shell
enable
configure terminal

# Tu as déjà "public" en RO, on ajoute "private" en RW
snmp-server community private RW

# Restriction d'accès à ton serveur de monitoring uniquement (recommandé)
access-list 10 permit 172.27.50.0 0.0.0.255
snmp-server community private RW 10

# Notification des changements d'état d'interface
snmp-server enable traps snmp linkdown linkup

# Sauvegarder
end
write memory
```

### Étape 3 : Vérification
```bash
# Depuis le switch
show snmp community

# Depuis le serveur de monitoring (test lecture - fonctionne déjà)
snmpwalk -v2c -c public 172.27.50.70 IF-MIB::ifDescr

# Test écriture sur une interface de test (⚠️ teste sur FastEthernet0/24 ou interface non utilisée)
# Récupère l'index de l'interface
snmpwalk -v2c -c public 172.27.50.70 IF-MIB::ifDescr | grep "FastEthernet0/24"
# Exemple sortie : IF-MIB::ifDescr.10024 = STRING: FastEthernet0/24

# Met l'interface en DOWN via SNMP (remplace 10024 par ton index)
snmpset -v2c -c private 172.27.50.70 1.3.6.1.2.1.2.2.1.7.10024 i 2

# Puis remet en UP pour vérifier que ça marche
snmpset -v2c -c private 172.27.50.70 1.3.6.1.2.1.2.2.1.7.10024 i 1

# Si tu obtiens "Timeout" ou "Authentication failure", vérifie la config ACL
```

---

## 🖥️ Partie 2 : Installation du module Auto-fix SNMP Write

### Étape 1 : Installation de pysnmp (si pas déjà fait)
```bash
pip3 install pysnmp
```

### Étape 2 : Créer le script `snmp-autofix.py`
```bash
sudo nano /opt/monitoring/snmp-autofix.py
```

**Contenu du fichier :**
```python
#!/usr/bin/env python3
"""
SNMP Auto-fix - Réactive une interface via SNMP SET
Usage: snmp-autofix.py <ip> <if_index> <interface_name> <community_rw>
"""

import sys
from pysnmp.hlapi import *
from datetime import datetime

LOG_FILE = "/var/log/snmp-autofix.log"

def log(message):
    """Écrit dans le fichier de log avec timestamp"""
    timestamp = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
    log_line = f"{timestamp} {message}"
    print(log_line)
    with open(LOG_FILE, "a") as f:
        f.write(log_line + "\n")

def snmp_set_interface_up(switch_ip, if_index, community_rw):
    """Met l'interface en UP via SNMP SET (ifAdminStatus = 1)"""
    try:
        log(f"[SNMP SET] Tentative de réactivation interface index {if_index} sur {switch_ip}")
        
        # OID pour ifAdminStatus : 1.3.6.1.2.1.2.2.1.7.<if_index>
        oid = f'1.3.6.1.2.1.2.2.1.7.{if_index}'
        
        # Envoi du SET (valeur 1 = UP)
        errorIndication, errorStatus, errorIndex, varBinds = next(
            setCmd(
                SnmpEngine(),
                CommunityData(community_rw),
                UdpTransportTarget((switch_ip, 161)),
                ContextData(),
                ObjectType(ObjectIdentity(oid), Integer(1))  # 1 = UP
            )
        )
        
        if errorIndication:
            log(f"[SNMP ERROR] {errorIndication}")
            return False
        elif errorStatus:
            log(f"[SNMP ERROR] {errorStatus.prettyPrint()} at {errorIndex and varBinds[int(errorIndex) - 1][0] or '?'}")
            return False
        else:
            log(f"[SNMP SUCCESS] Interface index {if_index} réactivée (ifAdminStatus = 1)")
            return True
            
    except Exception as e:
        log(f"[SNMP ERROR] Exception : {str(e)}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print("Usage: snmp-autofix.py <ip> <if_index> <interface_name> <community_rw>")
        sys.exit(1)
    
    switch_ip = sys.argv[1]
    if_index = sys.argv[2]
    interface_name = sys.argv[3]
    community_rw = sys.argv[4]
    
    log(f"[AUTO-FIX] Démarrage pour interface {interface_name} (index {if_index}) sur {switch_ip}")
    success = snmp_set_interface_up(switch_ip, if_index, community_rw)
    
    if success:
        log(f"[AUTO-FIX SUCCESS] Interface {interface_name} réactivée avec succès")
        sys.exit(0)
    else:
        log(f"[AUTO-FIX FAILED] Échec de la réactivation de {interface_name}")
        sys.exit(1)
```

### Étape 3 : Rendre le script exécutable
```bash
sudo chmod +x /opt/monitoring/snmp-autofix.py
```

### Étape 4 : Modifier ton snmp-poller.py existant

**Ajoute ces lignes au début du fichier (après les imports) :**
```python
# === AJOUT AUTO-FIX SNMP WRITE ===
AUTOFIX_ENABLED = True  # Active/désactive l'auto-fix
AUTOFIX_SWITCH_IP = "172.27.50.70"
AUTOFIX_COMMUNITY_RW = "private"  # Communauté SNMP Read-Write
SNMP_AUTOFIX_SCRIPT = "/opt/monitoring/snmp-autofix.py"
# Cache pour mapping nom interface <-> index SNMP
interface_index_cache = {}
# ==================================
```

**Ajoute cette fonction (après la fonction `log_alert`) :**
```python
def get_interface_index(ip, community, interface_name):
    """Récupère l'index SNMP d'une interface par son nom"""
    global interface_index_cache
    cache_key = f"{ip}_{interface_name}"
    
    # Utilise le cache si disponible
    if cache_key in interface_index_cache:
        return interface_index_cache[cache_key]
    
    try:
        # Récupère tous les noms d'interfaces
        cmd = ['snmpwalk', '-v2c', '-c', community, '-Onq', ip, '1.3.6.1.2.1.2.2.1.2']
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        
        if result.returncode == 0:
            for line in result.stdout.strip().split('\n'):
                if line.strip():
                    # Format: .1.3.6.1.2.1.2.2.1.2.10001 "FastEthernet0/1"
                    parts = line.split()
                    if len(parts) >= 2:
                        oid_part = parts[0]
                        name_part = ' '.join(parts[1:]).strip('"')
                        
                        # Extrait l'index (dernier nombre de l'OID)
                        if_index = oid_part.split('.')[-1]
                        
                        # Mise en cache
                        cache_key_found = f"{ip}_{name_part}"
                        interface_index_cache[cache_key_found] = if_index
                        
                        # Correspondance trouvée
                        if name_part == interface_name:
                            log_alert(f"[INDEX FOUND] {interface_name} = index {if_index}")
                            return if_index
        
        log_alert(f"[INDEX NOT FOUND] Impossible de trouver l'index pour {interface_name}")
        return None
        
    except Exception as e:
        log_alert(f"[INDEX ERROR] {str(e)}")
        return None

def trigger_snmp_autofix(device_name, device_ip, interface_name):
    """Déclenche l'auto-fix SNMP Write pour une interface shutdown"""
    if not AUTOFIX_ENABLED:
        return False
    
    # Uniquement pour le Switch-Core
    if "Switch-Core" not in device_name:
        return False
    
    # Exclusion des interfaces virtuelles
    if any(x in interface_name.lower() for x in ['null', 'vlan1', 'loopback', 'npu', 'ssl']):
        return False
    
    try:
        log_alert(f"[AUTO-FIX SNMP] Tentative de réactivation: {interface_name} sur {device_name}")
        
        # Récupère l'index SNMP de l'interface
        if_index = get_interface_index(device_ip, 'public', interface_name)
        
        if if_index is None:
            log_alert(f"[AUTO-FIX FAILED] Impossible de trouver l'index SNMP pour {interface_name}")
            return False
        
        # Lance le script SNMP autofix
        result = subprocess.run(
            [
                '/usr/bin/python3',
                SNMP_AUTOFIX_SCRIPT,
                AUTOFIX_SWITCH_IP,
                if_index,
                interface_name,
                AUTOFIX_COMMUNITY_RW
            ],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode == 0:
            log_alert(f"[AUTO-FIX SUCCESS] Interface {interface_name} (index {if_index}) réactivée via SNMP")
            send_alert_email(
                f"AUTO-FIX SUCCESS - {device_name}",
                f"Interface {interface_name} (index SNMP {if_index}) a été automatiquement réactivée via SNMP Write"
            )
            return True
        else:
            log_alert(f"[AUTO-FIX FAILED] {result.stderr}")
            return False
            
    except Exception as e:
        log_alert(f"[AUTO-FIX ERROR] {str(e)}")
        return False
```

**Modifie la fonction `get_interfaces_full` pour détecter les shutdown :**

Ajoute ce bloc **à la fin de la fonction `get_interfaces_full`**, juste avant le `return interfaces` (ligne ~200) :

```python
        # === DÉTECTION AUTO-FIX SNMP ===
        # Compare avec l'état précédent pour détecter les changements DOWN
        if hasattr(get_interfaces_full, 'last_state'):
            cache_key = f"{ip}_{device_type}"
            last_interfaces = get_interfaces_full.last_state.get(cache_key, {})
            
            for if_name, if_data in interfaces.items():
                last_status = last_interfaces.get(if_name, {}).get('status', 'unknown')
                current_status = if_data['status']
                
                # Détection d'un passage de 'up' à 'down'
                if last_status == 'up' and current_status == 'down':
                    log_alert(f"[SHUTDOWN DETECTED] {if_name} est passée DOWN sur {ip}")
                    # Appel de l'auto-fix (asynchrone pour ne pas bloquer)
                    import threading
                    threading.Thread(
                        target=trigger_snmp_autofix,
                        args=(name, ip, if_name),
                        daemon=True
                    ).start()
        
        # Sauvegarde de l'état pour la prochaine fois
        if not hasattr(get_interfaces_full, 'last_state'):
            get_interfaces_full.last_state = {}
        cache_key = f"{ip}_{device_type}"
        get_interfaces_full.last_state[cache_key] = interfaces.copy()
        # ===============================
```

**⚠️ Important :** Ajoute ce code **AVANT** le `return interfaces` à la ligne ~200.

### Étape 5 : Redémarrer ton service SNMP poller
```bash
sudo systemctl restart snmp-poller
```

### Étape 6 : Suivre les logs
```bash
# Logs du poller (avec détection shutdown)
tail -f /var/log/alerts.log

# Logs spécifiques SNMP auto-fix
tail -f /var/log/snmp-autofix.log
```

---

## ✅ Test de la solution

### Test manuel du script SNMP autofix
```bash
# 1. Trouve l'index d'une interface de test
snmpwalk -v2c -c public 172.27.50.70 IF-MIB::ifDescr | grep "FastEthernet0/10"
# Exemple : IF-MIB::ifDescr.10010 = STRING: FastEthernet0/10
# L'index est : 10010

# 2. Met l'interface en shutdown via SNMP
snmpset -v2c -c private 172.27.50.70 1.3.6.1.2.1.2.2.1.7.10010 i 2

# 3. Lance le script d'auto-fix
sudo /opt/monitoring/snmp-autofix.py 172.27.50.70 10010 FastEthernet0/10 private

# 4. Vérifie que l'interface est revenue UP
snmpget -v2c -c public 172.27.50.70 1.3.6.1.2.1.2.2.1.7.10010
# Doit retourner : INTEGER: 1 (up)

# 5. Vérifie les logs
tail -20 /var/log/snmp-autofix.log
```

### Test automatique via le poller
```bash
# 1. Arrête le service
sudo systemctl stop snmp-poller

# 2. Lance en mode debug (terminal)
cd /opt/monitoring
sudo python3 snmp-poller.py

# 3. Dans un autre terminal SSH, shutdown une interface via SNMP
# (utilise l'index trouvé précédemment)
snmpset -v2c -c private 172.27.50.70 1.3.6.1.2.1.2.2.1.7.10010 i 2

# 4. Observe les logs en temps réel dans le premier terminal
# Tu devrais voir (après max 30s = intervalle de polling) :
# [SHUTDOWN DETECTED] FastEthernet0/10 est passée DOWN
# [AUTO-FIX SNMP] Tentative de réactivation...
# [INDEX FOUND] FastEthernet0/10 = index 10010
# [AUTO-FIX SUCCESS] Interface FastEthernet0/10 réactivée
```

---

## 📊 Résumé de l'intégration

| Composant | Emplacement | Rôle |
|-----------|-------------|------|
| **snmp-poller.py** (modifié) | `/opt/monitoring/` | Détecte les interfaces DOWN + déclenche auto-fix |
| **snmp-autofix.py** (nouveau) | `/opt/monitoring/` | Réactive les interfaces via SNMP SET |
| **Logs SNMP Poller** | `/var/log/alerts.log` | Historique du monitoring |
| **Logs SNMP Auto-fix** | `/var/log/snmp-autofix.log` | Historique des auto-fix |

---

## 🔒 Sécurité

### ⚠️ Recommandations importantes

1. **Change la communauté SNMP RW en production**
   ```shell
   # Sur le switch
   no snmp-server community private RW
   snmp-server community Ma_Cle_Secrete_2024! RW 10
   ```
   
   Puis dans `/opt/monitoring/snmp-poller.py` :
   ```python
   AUTOFIX_COMMUNITY_RW = "Ma_Cle_Secrete_2024!"
   ```

2. **Restreins l'accès à ton serveur uniquement (déjà fait dans config ci-dessus)**
   ```shell
   access-list 10 permit 172.27.50.0 0.0.0.255
   ```

3. **Pour la production : passe en SNMPv3** (authentification + chiffrement)
   - Plus sécurisé que SNMPv2c
   - Nécessite configuration switch + adaptation scripts Python

---

## 🛠️ Dépannage

### Problème : SNMP SET refusé (Permission denied)
```bash
# Vérifier la communauté RW sur le switch
ssh admini@172.27.50.70
show snmp community

# Tester depuis le serveur
snmpset -v2c -c private 172.27.50.70 1.3.6.1.2.1.2.2.1.7.10 i 1
```

### Problème : Index d'interface incorrect
```bash
# Liste complète des interfaces avec leurs index
snmpwalk -v2c -c public 172.27.50.70 IF-MIB::ifDescr

# Vérifier la correspondance nom <-> index
snmpwalk -v2c -c public 172.27.50.70 IF-MIB::ifDescr | grep "FastEthernet"
```

### Problème : Script ne trouve pas l'index
```bash
# Vide le cache et relance
sudo systemctl restart snmp-poller

# Vérifie les logs
tail -f /var/log/alerts.log | grep "INDEX"
```

### Problème : Timeout SNMP
```bash
# Vérifier la connectivité
ping 172.27.50.70

# Vérifier le port SNMP (161)
sudo nmap -sU -p 161 172.27.50.70

# Vérifier les ACL sur le switch
ssh admini@172.27.50.70
show access-lists
```

---

## 🎛️ Configuration avancée

### Désactiver temporairement l'auto-fix
Édite `/opt/monitoring/snmp-poller.py` :
```python
AUTOFIX_ENABLED = False  # Désactive l'auto-fix
```

Puis redémarre :
```bash
sudo systemctl restart snmp-poller
```

### Activer l'auto-fix pour d'autres switches
Modifie la fonction `trigger_snmp_autofix` :
```python
# Remplace cette ligne :
if "Switch-Core" not in device_name:

# Par celle-ci pour activer sur tous les switches Cisco :
if device_type not in ['cisco', 'cisco_routeur']:
```

### Ajuster l'intervalle de polling
Dans `/opt/monitoring/snmp-poller.py`, ligne ~350 :
```python
time.sleep(30)  # Change 30 par 10 pour polling toutes les 10s
```

---

## 🔄 Comparaison avec solution Telnet

| Critère | Telnet | SNMP Write |
|---------|--------|------------|
| **Sécurité** | ❌ Faible (texte clair) | ✅ Meilleure (avec SNMPv3) |
| **Performance** | 🟡 Moyenne (session TCP) | ✅ Rapide (UDP, léger) |
| **Complexité** | 🟡 Moyenne (pexpect) | ✅ Simple (SNMP SET) |
| **Dépendances** | pexpect, telnet | pysnmp (déjà installé) |
| **Compatibilité** | ✅ Tous switches Cisco | ✅ Tous switches managés |
| **Production** | ❌ Déconseillé | ✅ **Recommandé** |

---

## 📈 Améliorations possibles

### 1. Notification email améliorée
Le script envoie déjà un email lors d'un auto-fix réussi (via `send_alert_email`).

### 2. Dashboard web temps réel
Ton script génère déjà `/var/lib/monitoring/metrics.json` avec historique.  
Tu peux créer un dashboard web pour visualiser :
- Nombre d'auto-fix par jour
- Interfaces les plus instables
- Temps de réactivation moyen

### 3. Historique des auto-fix dans metrics.json
Ajoute dans `trigger_snmp_autofix` :
```python
# Après un auto-fix réussi
try:
    with open('/var/lib/monitoring/autofix_history.json', 'a') as f:
        json.dump({
            'timestamp': datetime.now().isoformat(),
            'device': device_name,
            'interface': interface_name,
            'index': if_index,
            'success': True
        }, f)
        f.write('\n')
except:
    pass
```

---

✅ **Solution SNMP Write intégrée à ton poller existant !**

**Cette solution est RECOMMANDÉE pour la production** car :
- ✅ Plus sécurisée (surtout avec SNMPv3)
- ✅ Plus performante (UDP, pas de session TCP)
- ✅ Standard de l'industrie pour l'automatisation réseau
- ✅ S'intègre parfaitement à ton infrastructure SNMP existante
