# Solution 1 : Auto-fix Telnet (intégration avec snmp-poller existant)

## 🎯 Architecture
- **Ton snmp-poller.py existant** : Continue de surveiller les interfaces
- **telnet-autofix.py** : Nouveau script pour réactiver via Telnet
- **Modification du poller** : Appelle l'auto-fix quand interface DOWN détectée

---

## 🔧 Partie 1 : Configuration du Switch (Cisco Catalyst 2960+)

### Étape 1 : Activation de Telnet sur le switch
```bash
# Connexion au switch
ssh admini@172.27.50.70
```

### Étape 2 : Configuration VTY pour Telnet + SSH
```shell
enable
configure terminal

# Configuration des lignes VTY (0 à 4 pour 5 connexions simultanées)
line vty 0 4
  login local
  transport input ssh telnet    # SSH ET Telnet activés
  exec-timeout 5 0              # Timeout 5 minutes
exit

# Vérifier que SSH v2 est actif
ip ssh version 2

# Sauvegarder
end
write memory
```

### Étape 3 : Vérification
```bash
# Test depuis le serveur de monitoring
telnet 172.27.50.70
# (login: admini / password: admin1)

# Si connexion OK, tapez 'exit' pour quitter
```

---

## 🖥️ Partie 2 : Installation du module Auto-fix Telnet

### Étape 1 : Installation de pexpect
```bash
pip3 install pexpect
```

### Étape 2 : Créer le script `telnet-autofix.py`
```bash
sudo nano /opt/monitoring/telnet-autofix.py
```

**Contenu du fichier :**
```python
#!/usr/bin/env python3
"""
Telnet Auto-fix - Réactive une interface via Telnet
Usage: telnet-autofix.py <ip> <interface_name> <username> <password>
"""

import sys
import pexpect
from datetime import datetime

LOG_FILE = "/var/log/telnet-autofix.log"

def log(message):
    """Écrit dans le fichier de log avec timestamp"""
    timestamp = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
    log_line = f"{timestamp} {message}"
    print(log_line)
    with open(LOG_FILE, "a") as f:
        f.write(log_line + "\n")

def telnet_no_shutdown(switch_ip, interface_name, username, password):
    """Se connecte en Telnet et exécute 'no shutdown' sur l'interface"""
    try:
        log(f"[TELNET] Connexion à {switch_ip} pour {interface_name}")
        
        # Connexion Telnet
        child = pexpect.spawn(f'telnet {switch_ip}', timeout=10, encoding='utf-8')
        
        # Login
        child.expect('Username:', timeout=5)
        child.sendline(username)
        log(f"[TELNET] Username envoyé")
        
        child.expect('Password:', timeout=5)
        child.sendline(password)
        log(f"[TELNET] Password envoyé")
        
        # Attente du prompt utilisateur (>)
        child.expect(r'[>#]', timeout=5)
        log(f"[TELNET] Connecté en mode user")
        
        # Passage en mode enable
        child.sendline('enable')
        child.expect('Password:', timeout=5)
        child.sendline(password)  # Même mot de passe pour enable
        child.expect(r'#', timeout=5)
        log(f"[TELNET] Mode enable activé")
        
        # Configuration
        child.sendline('configure terminal')
        child.expect(r'\(config\)#', timeout=5)
        log(f"[TELNET] Mode configuration")
        
        child.sendline(f'interface {interface_name}')
        child.expect(r'\(config-if\)#', timeout=5)
        log(f"[TELNET] Interface {interface_name} sélectionnée")
        
        child.sendline('no shutdown')
        child.expect(r'\(config-if\)#', timeout=5)
        log(f"[TELNET] Commande 'no shutdown' envoyée")
        
        child.sendline('end')
        child.expect(r'#', timeout=5)
        
        # Sauvegarde
        child.sendline('write memory')
        child.expect(r'#', timeout=10)
        log(f"[TELNET] Configuration sauvegardée")
        
        # Déconnexion
        child.sendline('exit')
        child.close()
        
        log(f"[TELNET SUCCESS] Interface {interface_name} réactivée avec succès")
        return True
        
    except pexpect.TIMEOUT:
        log(f"[TELNET TIMEOUT] Délai dépassé lors de la connexion")
        return False
    except pexpect.EOF:
        log(f"[TELNET EOF] Connexion fermée prématurément")
        return False
    except Exception as e:
        log(f"[TELNET ERROR] {str(e)}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print("Usage: telnet-autofix.py <ip> <interface_name> <username> <password>")
        sys.exit(1)
    
    switch_ip = sys.argv[1]
    interface_name = sys.argv[2]
    username = sys.argv[3]
    password = sys.argv[4]
    
    success = telnet_no_shutdown(switch_ip, interface_name, username, password)
    sys.exit(0 if success else 1)
```

### Étape 3 : Rendre le script exécutable
```bash
sudo chmod +x /opt/monitoring/telnet-autofix.py
```

### Étape 4 : Modifier ton snmp-poller.py existant

**Ajoute ces lignes au début du fichier (après les imports) :**
```python
# === AJOUT AUTO-FIX TELNET ===
AUTOFIX_ENABLED = True  # Active/désactive l'auto-fix
AUTOFIX_SWITCH_IP = "172.27.50.70"
AUTOFIX_USERNAME = "admini"
AUTOFIX_PASSWORD = "admin1"
TELNET_AUTOFIX_SCRIPT = "/opt/monitoring/telnet-autofix.py"
# ==============================
```

**Ajoute cette fonction (après la fonction `log_alert`) :**
```python
def trigger_telnet_autofix(device_name, interface_name):
    """Déclenche l'auto-fix Telnet pour une interface shutdown"""
    if not AUTOFIX_ENABLED:
        return False
    
    # Uniquement pour le Switch-Core
    if "Switch-Core" not in device_name:
        return False
    
    # Exclusion des interfaces virtuelles
    if any(x in interface_name.lower() for x in ['null', 'vlan1', 'loopback', 'npu', 'ssl']):
        return False
    
    try:
        log_alert(f"[AUTO-FIX TELNET] Tentative de réactivation: {interface_name} sur {device_name}")
        
        result = subprocess.run(
            [
                '/usr/bin/python3',
                TELNET_AUTOFIX_SCRIPT,
                AUTOFIX_SWITCH_IP,
                interface_name,
                AUTOFIX_USERNAME,
                AUTOFIX_PASSWORD
            ],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            log_alert(f"[AUTO-FIX SUCCESS] Interface {interface_name} réactivée via Telnet")
            send_alert_email(
                f"AUTO-FIX SUCCESS - {device_name}",
                f"Interface {interface_name} a été automatiquement réactivée via Telnet"
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

Ajoute ce bloc **à la fin de la fonction `get_interfaces_full`**, juste avant le `return interfaces` :

```python
        # === DÉTECTION AUTO-FIX ===
        # Compare avec l'état précédent pour détecter les changements DOWN
        if hasattr(get_interfaces_full, 'last_state'):
            for if_name, if_data in interfaces.items():
                last_status = get_interfaces_full.last_state.get(device_type, {}).get(if_name, {}).get('status', 'unknown')
                current_status = if_data['status']
                
                # Détection d'un passage de 'up' à 'down'
                if last_status == 'up' and current_status == 'down':
                    log_alert(f"[SHUTDOWN DETECTED] {if_name} est passée DOWN sur {ip}")
                    # Appel de l'auto-fix (asynchrone pour ne pas bloquer)
                    import threading
                    threading.Thread(
                        target=trigger_telnet_autofix,
                        args=(name, if_name),
                        daemon=True
                    ).start()
        
        # Sauvegarde de l'état pour la prochaine fois
        if not hasattr(get_interfaces_full, 'last_state'):
            get_interfaces_full.last_state = {}
        if device_type not in get_interfaces_full.last_state:
            get_interfaces_full.last_state[device_type] = {}
        get_interfaces_full.last_state[device_type] = interfaces.copy()
        # ==========================
```

**⚠️ Important :** Ajoute ce code **AVANT** le `return interfaces` à la ligne ~200 de ton script.

### Étape 5 : Redémarrer ton service SNMP poller
```bash
sudo systemctl restart snmp-poller
```

### Étape 6 : Suivre les logs
```bash
# Logs du poller (avec détection shutdown)
tail -f /var/log/alerts.log

# Logs spécifiques Telnet auto-fix
tail -f /var/log/telnet-autofix.log
```

---

## ✅ Test de la solution

### Test manuel du script Telnet
```bash
# Test direct du script
sudo /opt/monitoring/telnet-autofix.py 172.27.50.70 FastEthernet0/10 admini admin1

# Vérifie les logs
tail -20 /var/log/telnet-autofix.log
```

### Test automatique via le poller
```bash
# 1. Arrête le service
sudo systemctl stop snmp-poller

# 2. Lance en mode debug (terminal)
cd /opt/monitoring
sudo python3 snmp-poller.py

# 3. Dans un autre terminal SSH, shutdown une interface sur le switch
ssh admini@172.27.50.70
enable
configure terminal
interface FastEthernet0/10
shutdown
exit

# 4. Observe les logs en temps réel dans le premier terminal
# Tu devrais voir :
# [SHUTDOWN DETECTED] FastEthernet0/10 est passée DOWN
# [AUTO-FIX TELNET] Tentative de réactivation...
# [AUTO-FIX SUCCESS] Interface FastEthernet0/10 réactivée
```

---

## 📊 Résumé de l'intégration

| Composant | Emplacement | Rôle |
|-----------|-------------|------|
| **snmp-poller.py** (modifié) | `/opt/monitoring/` | Détecte les interfaces DOWN + déclenche auto-fix |
| **telnet-autofix.py** (nouveau) | `/opt/monitoring/` | Réactive les interfaces via Telnet |
| **Logs SNMP** | `/var/log/alerts.log` | Historique du monitoring |
| **Logs Telnet** | `/var/log/telnet-autofix.log` | Historique des auto-fix |

---

## 🔒 Sécurité

⚠️ **Telnet transmet les mots de passe en clair sur le réseau !**
- À utiliser **uniquement sur réseau local/lab sécurisé**
- Pour la production, préférer la solution SNMP Write (voir fichier 2)

---

## 🛠️ Dépannage

### Problème : Telnet refuse la connexion
```bash
# Test manuel
telnet 172.27.50.70
# (login: admini / password: admin1)
```

### Problème : Script ne détecte pas les changements
```bash
# Vérifier que la modification du poller est bien prise en compte
grep -A5 "DÉTECTION AUTO-FIX" /opt/monitoring/snmp-poller.py

# Vérifier les logs
tail -f /var/log/alerts.log
```

### Problème : pexpect timeout
```bash
# Augmenter les timeouts dans telnet-autofix.py (ligne 18)
# child = pexpect.spawn(f'telnet {switch_ip}', timeout=20, ...)

# Tester la latence réseau
ping 172.27.50.70
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
Modifie la fonction `trigger_telnet_autofix` :
```python
# Remplace cette ligne :
if "Switch-Core" not in device_name:

# Par celle-ci pour activer sur tous les switches Cisco :
if device_type not in ['cisco', 'cisco_routeur']:
```

---

✅ **Solution Telnet intégrée à ton poller existant !**

**Avantages de cette approche :**
- ✅ Garde ton excellent script SNMP existant
- ✅ Ajoute juste le module d'auto-fix
- ✅ Minimal et modulaire
- ✅ Facile à désactiver si besoin
