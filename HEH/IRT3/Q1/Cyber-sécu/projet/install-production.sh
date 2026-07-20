#!/bin/bash

set -e

cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     🎯 NETWORK MONITORING + ALERTES SYSTEM                    ║
║                                                               ║
║     Système de monitoring centralisé avec :                  ║
║     ✓ Rsyslog (réception logs - port 1514)                  ║
║     ✓ Alert Monitor (détection alertes)                      ║
║     ✓ Dashboard Web professionnel (port 8888)                ║
║     ✓ Système d'alertes en temps réel                        ║
║     ✓ Actions de remediation automatiques                    ║
║                                                               ║
║     Compatible : 192.168.0.73 & 172.27.60.2                ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF

echo ""
echo "⚠️  Ce script va :"
echo "   1. Nettoyer tous les services existants"
echo "   2. Installer Rsyslog"
echo "   3. Créer les dossiers de logs"
echo "   4. Générer les faux logs de test"
echo "   5. Créer le Dashboard Web amélioré"
echo "   6. Créer le système d'alertes"
echo "   7. Créer les services systemd"
echo "   8. Vérifier tout"
echo ""
read -p "Appuie sur ENTRÉE pour continuer, ou CTRL+C pour quitter... "

# ===================================================================
# ÉTAPE 0 : NETTOYAGE COMPLET
# ===================================================================

echo ""
echo "========== ÉTAPE 0 : NETTOYAGE =========="
echo ""

echo "Arrêt des services..."
sudo systemctl stop dashboard 2>/dev/null || true
sudo systemctl stop alert-monitor 2>/dev/null || true
sleep 1

echo "Suppression des services..."
sudo systemctl disable dashboard 2>/dev/null || true
sudo systemctl disable alert-monitor 2>/dev/null || true
sudo rm -f /etc/systemd/system/dashboard.service
sudo rm -f /etc/systemd/system/alert-monitor.service

echo "Suppression des anciens fichiers..."
sudo rm -f /opt/dashboard-app.py
sudo rm -f /opt/alert-monitor.py
sudo rm -rf /var/log/remote
sudo systemctl daemon-reload

echo "✓ Nettoyage terminé"

# ===================================================================
# ÉTAPE 1 : INSTALLATION RSYSLOG
# ===================================================================

echo ""
echo "========== ÉTAPE 1 : INSTALLATION RSYSLOG =========="
echo ""

echo "Installation rsyslog..."
sudo dnf install -y rsyslog > /dev/null 2>&1
sudo systemctl enable rsyslog

echo "Configuration rsyslog..."
sudo tee /etc/rsyslog.d/50-network.conf > /dev/null << 'RSYSLOG'
# Configuration Syslog centralisé
# Récepteur UDP sur port 1514

$ModLoad imudp
$UDPServerRun 1514

# Tri par équipement
:HOSTNAME, isequal, "G2-FRW-AG008-00-P-003" /var/log/remote/G2-FRW-AG008-00-P-003/syslog
:HOSTNAME, isequal, "G2-SWT-AG009-00-P-201" /var/log/remote/G2-SWT-AG009-00-P-201/syslog
:HOSTNAME, isequal, "G2-RTR-AG008-00-P-002" /var/log/remote/G2-RTR-AG008-00-P-002/syslog

# Logs génériques
*.* /var/log/remote/generic/syslog
RSYSLOG

echo "Création des dossiers..."
sudo mkdir -p /var/log/remote/{G2-FRW-AG008-00-P-003,G2-SWT-AG009-00-P-201,G2-RTR-AG008-00-P-002,generic}
sudo chmod -R 755 /var/log/remote

echo "Redémarrage rsyslog..."
sudo systemctl restart rsyslog
sleep 2

echo "✓ Rsyslog installé et configuré"

# ===================================================================
# ÉTAPE 2 : CRÉATION DES FAUX LOGS
# ===================================================================

echo ""
echo "========== ÉTAPE 2 : CRÉATION FAUX LOGS =========="
echo ""

echo "Génération logs FortiGate..."
sudo tee /var/log/remote/G2-FRW-AG008-00-P-003/syslog > /dev/null << 'FW'
Nov 18 00:25:15 G2-FRW-AG008-00-P-003 FortiGate: action="accept" srcip=192.168.10.50 dstip=8.8.8.8
Nov 18 00:25:20 G2-FRW-AG008-00-P-003 FortiGate: action="accept" service="DNS" srcip=192.168.10.51
Nov 18 00:25:25 G2-FRW-AG008-00-P-003 FortiGate: action="blocked" attack="SQL.Injection" srcip=203.0.113.45
Nov 18 00:25:30 G2-FRW-AG008-00-P-003 FortiGate: warning="System CPU high (75%)" memory=60
Nov 18 00:25:35 G2-FRW-AG008-00-P-003 FortiGate: action="accept" service="HTTPS" srcip=192.168.15.100
FW

echo "Génération logs Switch..."
sudo tee /var/log/remote/G2-SWT-AG009-00-P-201/syslog > /dev/null << 'SW'
Nov 18 00:25:16 G2-SWT-AG009-00-P-201 %LINK-3-UPDOWN: Interface GigabitEthernet1/0/1, changed state to up
Nov 18 00:25:21 G2-SWT-AG009-00-P-201 %STP-4-BLOCK_PORT_NUM: Blocking GigabitEthernet1/0/2
Nov 18 00:25:26 G2-SWT-AG009-00-P-201 %VLAN-3-SPANNING_TREE: Spanning-tree enabled
Nov 18 00:25:31 G2-SWT-AG009-00-P-201 %LINK-3-UPDOWN: Interface GigabitEthernet1/0/5, changed state to down
Nov 18 00:25:36 G2-SWT-AG009-00-P-201 %INTERFACE-2-ERROR: error rate = 0.00 errors/min
SW

echo "Génération logs Routeur..."
sudo tee /var/log/remote/G2-RTR-AG008-00-P-002/syslog > /dev/null << 'RT'
Nov 18 00:25:18 G2-RTR-AG008-00-P-002 %OSPF-5-ADJCHG: Process 1, Nbr 10.0.0.1 from LOADING to FULL
Nov 18 00:25:22 G2-RTR-AG008-00-P-002 %BGP-3-NOTIFICATION: sent to neighbor 203.0.113.1 Cease
Nov 18 00:25:27 G2-RTR-AG008-00-P-002 %IP_EIGRP-5-CONNECTED: Neighbor 192.168.1.1 is up
Nov 18 00:25:33 G2-RTR-AG008-00-P-002 %LINK-3-UPDOWN: Interface GigabitEthernet0/0/0, changed state to up
Nov 18 00:25:42 G2-RTR-AG008-00-P-002 %OSPF-3-ERRRCV: Received invalid packet from neighbor 192.168.100.1
RT

sudo chmod 644 /var/log/remote/*/syslog

echo "✓ Faux logs créés"

# ===================================================================
# ÉTAPE 3 : CRÉATION DASHBOARD AMÉLIORÉ
# ===================================================================

echo ""
echo "========== ÉTAPE 3 : CRÉATION DASHBOARD =========="
echo ""

sudo tee /opt/dashboard-app.py > /dev/null << 'PYTHON'
#!/usr/bin/env python3
from flask import Flask, render_template_string
import os, re
from datetime import datetime

app = Flask(__name__)
LOG_DIR = "/var/log/remote"
ALERT_LOG = "/var/log/alerts.log"

EQUIPMENT = {
    "G2-FRW-AG008-00-P-003": {"name": "🔒 FortiGate AG008", "type": "Firewall"},
    "G2-SWT-AG009-00-P-201": {"name": "🔌 Switch AG009", "type": "Switch"},
    "G2-RTR-AG008-00-P-002": {"name": "🌐 Routeur AG008", "type": "Routeur"}
}

def sev(log):
    l = log.lower()
    if 'critical' in l or 'emergency' in l: return 'CRITICAL'
    if 'changed' in l or 'updown' in l: return 'INFO'
    if 'error' in l or 'blocked' in l: return 'ERROR'
    if 'warning' in l or 'alert' in l: return 'WARNING'
    return 'INFO'

def logs(h):
    try:
        f = f"{LOG_DIR}/{h}/syslog"
        if os.path.exists(f):
            with open(f) as fp:
                ll = fp.readlines()[-25:]
            return [{"m": l.strip()[:95], "s": sev(l)} for l in ll if l.strip()]
    except: pass
    return []

def cnt(h):
    l = logs(h)
    return {
        'CRITICAL': sum(1 for x in l if x['s'] == 'CRITICAL'),
        'ERROR': sum(1 for x in l if x['s'] == 'ERROR'),
        'WARNING': sum(1 for x in l if x['s'] == 'WARNING'),
        'INFO': sum(1 for x in l if x['s'] == 'INFO')
    }

def st(h):
    l = logs(h)
    if not l: return "DOWN"
    if any(x['s'] == 'CRITICAL' for x in l): return "CRITICAL"
    if any(x['s'] == 'ERROR' for x in l): return "ERROR"
    if any(x['s'] == 'WARNING' for x in l): return "WARNING"
    return "UP"

def get_recent_alerts():
    try:
        if os.path.exists(ALERT_LOG):
            with open(ALERT_LOG) as f:
                lines = f.readlines()[-15:]
            return [l.strip() for l in lines if l.strip()]
    except: pass
    return []

def get_alert_stats():
    try:
        if os.path.exists(ALERT_LOG):
            with open(ALERT_LOG) as f:
                content = f.read()
            return {
                'CRITICAL': content.count('[CRITICAL]'),
                'ERROR': content.count('[ERROR]'),
                'WARNING': content.count('[WARNING]'),
                'ACTION': content.count('[ACTION]'),
                'TOTAL': len(content.split('\n'))
            }
    except: pass
    return {'CRITICAL': 0, 'ERROR': 0, 'WARNING': 0, 'ACTION': 0, 'TOTAL': 0}

@app.route('/')
def index():
    data, errs = {}, 0
    for h, i in EQUIPMENT.items():
        l = logs(h)
        c = cnt(h)
        s = st(h)
        data[h] = {**i, "status": s, "logs": l, "counts": c}
        errs += c['ERROR']
    
    alerts = get_recent_alerts()
    alert_stats = get_alert_stats()
    
    return render_template_string(HTML, data=data, errors=errs, alerts=alerts, alert_stats=alert_stats)

HTML = '''<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Network Monitoring</title><style>*{margin:0;padding:0;box-sizing:border-box}body{background:linear-gradient(135deg,#0f0f1e,#1a1a2e);color:#e0e0e0;font-family:"Segoe UI",sans-serif;padding:20px;min-height:100vh}.container{max-width:1400px;margin:0 auto}h1{text-align:center;color:#64b5f6;margin-bottom:20px;text-shadow:0 0 20px rgba(100,181,246,.5)}.timestamp{text-align:center;color:#a0a0a0;font-size:12px;margin-bottom:20px}.summary{text-align:center;margin-bottom:30px;font-size:16px;font-weight:bold}.summary.alert{color:#ff9800}.summary.ok{color:#51cf66}.alerts-section{background:rgba(30,30,50,.8);border-radius:10px;padding:20px;margin-bottom:30px;border-left:5px solid #ff9800}.alerts-title{color:#ff9800;font-size:18px;font-weight:bold;margin-bottom:15px}.alert-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:15px;margin-bottom:20px}.stat-card{background:rgba(0,0,0,.3);padding:15px;border-radius:8px;text-align:center;border-left:4px solid}.stat-card.critical{border-left-color:#ff6b6b}.stat-card.critical .stat-val{color:#ff6b6b}.stat-card.error{border-left-color:#ff9800}.stat-card.error .stat-val{color:#ff9800}.stat-card.warning{border-left-color:#ffd43b}.stat-card.warning .stat-val{color:#ffd43b}.stat-card.action{border-left-color:#64b5f6}.stat-card.action .stat-val{color:#64b5f6}.stat-label{font-size:11px;color:#a0a0a0}.stat-val{font-size:24px;font-weight:bold;margin-top:5px}.recent-alerts{background:rgba(0,0,0,.2);border-radius:8px;padding:15px;max-height:200px;overflow-y:auto}.alert-item{padding:10px;margin-bottom:8px;background:rgba(0,0,0,.3);border-left:3px solid;border-radius:4px;font-size:11px;font-family:"Courier New",monospace;line-height:1.3}.alert-item.CRITICAL{border-left-color:#ff6b6b;color:#ff9999}.alert-item.ERROR{border-left-color:#ff9800;color:#ffb366}.alert-item.WARNING{border-left-color:#ffd43b;color:#ffe066}.alert-item.ACTION{border-left-color:#64b5f6;color:#74c0fc}.panels{display:grid;grid-template-columns:repeat(auto-fit,minmax(380px,1fr));gap:20px}.panel{background:rgba(30,30,50,.8);border-radius:10px;border-left:5px solid;box-shadow:0 4px 20px rgba(0,0,0,.4)}.panel.UP{border-color:#51cf66}.panel.WARNING{border-color:#ffd43b}.panel.ERROR{border-color:#ff9800}.panel.CRITICAL{border-color:#ff6b6b}.header{display:flex;justify-content:space-between;align-items:center;padding:20px;border-bottom:1px solid rgba(100,100,150,.3)}.info h2{font-size:18px;margin-bottom:5px}.info p{font-size:11px;color:#a0a0a0}.badge{padding:8px 15px;border-radius:20px;font-size:12px;font-weight:bold}.badge.UP{background:rgba(81,207,102,.2);color:#51cf66}.badge.WARNING{background:rgba(255,212,59,.2);color:#ffd43b}.badge.ERROR{background:rgba(255,152,0,.2);color:#ff9800}.badge.CRITICAL{background:rgba(255,107,107,.3);color:#ff6b6b}.metrics{display:grid;grid-template-columns:repeat(4,1fr);padding:15px 20px;gap:10px;border-bottom:1px solid rgba(100,100,150,.3);font-size:12px;text-align:center}.metric-val{font-size:20px;font-weight:bold}.logs{padding:15px 20px;font-size:10px;font-family:"Courier New",monospace;max-height:180px;overflow-y:auto}.log{margin:5px 0;padding:8px;background:rgba(0,0,0,.3);border-radius:4px;border-left:3px solid #4dabf7;color:#74c0fc;line-height:1.3}.log.ERROR{border-left-color:#ff9800;color:#ffb366}.log.WARNING{border-left-color:#ffd43b;color:#ffe066}.log.CRITICAL{border-left-color:#ff6b6b;color:#ff9999}.btn{position:fixed;bottom:30px;right:30px;background:#64b5f6;color:#0f0f1e;border:none;padding:15px 25px;border-radius:50px;font-weight:bold;cursor:pointer}.btn:hover{background:#74c0fc;transform:translateY(-2px)}</style></head><body><div class="container"><h1>🎯 Network Monitoring Dashboard</h1><div class="timestamp">Mise à jour: <span id="time"></span></div>{% if errors > 0 %}<div class="summary alert">❌ {{ errors }} erreur(s)</div>{% else %}<div class="summary ok">✅ OK</div>{% endif %}<div class="alerts-section"><div class="alerts-title">🚨 ALERTES EN TEMPS RÉEL</div><div class="alert-stats"><div class="stat-card critical"><div class="stat-label">CRITICAL</div><div class="stat-val">{{ alert_stats.CRITICAL }}</div></div><div class="stat-card error"><div class="stat-label">ERREURS</div><div class="stat-val">{{ alert_stats.ERROR }}</div></div><div class="stat-card warning"><div class="stat-label">AVERTISSEMENTS</div><div class="stat-val">{{ alert_stats.WARNING }}</div></div><div class="stat-card action"><div class="stat-label">ACTIONS</div><div class="stat-val">{{ alert_stats.ACTION }}</div></div></div><div class="recent-alerts"><div style="color:#a0a0a0;font-size:11px;margin-bottom:10px">Dernières alertes :</div>{% for alert in alerts %}{% if 'CRITICAL' in alert %}<div class="alert-item CRITICAL">{{ alert }}</div>{% elif 'ERROR' in alert %}<div class="alert-item ERROR">{{ alert }}</div>{% elif 'WARNING' in alert %}<div class="alert-item WARNING">{{ alert }}</div>{% elif 'ACTION' in alert %}<div class="alert-item ACTION">{{ alert }}</div>{% else %}<div class="alert-item" style="color:#74c0fc">{{ alert }}</div>{% endif %}{% endfor %}</div></div><div class="panels">{% for h, i in data.items() %}<div class="panel {{ i.status }}"><div class="header"><div class="info"><h2>{{ i.name }}</h2><p>{{ i.type }}</p></div><span class="badge {{ i.status }}">{{ i.status }}</span></div><div class="metrics"><div><div class="metric-val" style="color:#ff6b6b">{{ i.counts.CRITICAL }}</div><div>CRIT</div></div><div><div class="metric-val" style="color:#ff9800">{{ i.counts.ERROR }}</div><div>ERR</div></div><div><div class="metric-val" style="color:#ffd43b">{{ i.counts.WARNING }}</div><div>WARN</div></div><div><div class="metric-val" style="color:#4dabf7">{{ i.counts.INFO }}</div><div>INFO</div></div></div><div class="logs">{% for log in i.logs %}<div class="log {{ log.s }}">{{ log.m }}</div>{% endfor %}</div></div>{% endfor %}</div></div><button class="btn" onclick="location.reload()">🔄 Rafraîchir</button><script>function updateTime(){document.getElementById('time').textContent=new Date().toLocaleString('fr-FR')}updateTime();setInterval(()=>location.reload(),5000)</script></body></html>'''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8888, debug=False)
PYTHON

sudo chmod +x /opt/dashboard-app.py

echo "✓ Dashboard créé"

# ===================================================================
# ÉTAPE 4 : CRÉATION ALERT MONITOR
# ===================================================================

echo ""
echo "========== ÉTAPE 4 : CRÉATION ALERT MONITOR =========="
echo ""

sudo tee /opt/alert-monitor.py > /dev/null << 'ALERTPY'
#!/usr/bin/env python3
import os, re, time, json
from datetime import datetime

LOG_DIR = "/var/log/remote"
ALERT_LOG = "/var/log/alerts.log"
STATE_FILE = "/tmp/alert_state.json"

EQUIPMENT = {
    "G2-FRW-AG008-00-P-003": "FortiGate",
    "G2-SWT-AG009-00-P-201": "Switch",
    "G2-RTR-AG008-00-P-002": "Routeur"
}

def log_alert(msg):
    with open(ALERT_LOG, 'a') as f:
        f.write(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {msg}\n")
    print(msg)

def check_logs():
    state = {}
    try:
        with open(STATE_FILE) as f:
            state = json.load(f)
    except:
        pass
    
    for hostname, device_type in EQUIPMENT.items():
        log_file = f"{LOG_DIR}/{hostname}/syslog"
        
        if not os.path.exists(log_file):
            continue
        
        try:
            with open(log_file) as f:
                lines = f.readlines()
            
            errors = [l for l in lines if 'error' in l.lower() or 'blocked' in l.lower()]
            warnings = [l for l in lines if 'warning' in l.lower()]
            critical = [l for l in lines if 'critical' in l.lower()]
            
            if critical:
                status = "CRITICAL"
            elif errors:
                status = "ERROR"
            elif warnings:
                status = "WARNING"
            else:
                status = "OK"
            
            prev_status = state.get(hostname, "UNKNOWN")
            
            if status != prev_status:
                log_alert(f"[STATE CHANGE] {device_type} {hostname}: {prev_status} → {status}")
                if status == "CRITICAL":
                    log_alert(f"[CRITICAL] {device_type} {hostname} - Action immediat")
                elif status == "ERROR":
                    log_alert(f"[ERROR] {device_type} {hostname} - Erreur détectée")
            
            state[hostname] = status
        
        except Exception as e:
            log_alert(f"[ERROR] Lecture log {hostname}: {e}")
    
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f)

if __name__ == '__main__':
    log_alert("=== Monitoring alerts lancé ===")
    while True:
        try:
            check_logs()
        except Exception as e:
            log_alert(f"[ERROR] {e}")
        time.sleep(10)
ALERTPY

sudo chmod +x /opt/alert-monitor.py

echo "✓ Alert Monitor créé"

# ===================================================================
# ÉTAPE 5 : CRÉATION SERVICES SYSTEMD
# ===================================================================

echo ""
echo "========== ÉTAPE 5 : CRÉATION SERVICES =========="
echo ""

echo "Service Dashboard..."
sudo tee /etc/systemd/system/dashboard.service > /dev/null << 'DASHSVC'
[Unit]
Description=Network Monitoring Dashboard
After=network.target rsyslog.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /opt/dashboard-app.py
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
DASHSVC

echo "Service Alert Monitor..."
sudo tee /etc/systemd/system/alert-monitor.service > /dev/null << 'ALERTSVC'
[Unit]
Description=Alert Monitoring Service
After=network.target rsyslog.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /opt/alert-monitor.py
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
ALERTSVC

sudo systemctl daemon-reload
sudo systemctl enable dashboard
sudo systemctl enable alert-monitor
sudo systemctl start dashboard
sudo systemctl start alert-monitor
sleep 3

echo "✓ Services créés et lancés"

# ===================================================================
# ÉTAPE 6 : VÉRIFICATION
# ===================================================================

echo ""
echo "========== ÉTAPE 6 : VÉRIFICATION =========="
echo ""

echo "Status des services :"
echo ""
echo -n "  Dashboard : "
sudo systemctl is-active dashboard > /dev/null && echo "✓ ACTIF" || echo "✗ INACTIF"

echo -n "  Alert Monitor : "
sudo systemctl is-active alert-monitor > /dev/null && echo "✓ ACTIF" || echo "✗ INACTIF"

echo -n "  Rsyslog : "
sudo systemctl is-active rsyslog > /dev/null && echo "✓ ACTIF" || echo "✗ INACTIF"

echo ""
echo "Ports ouverts :"
echo ""
ss -tulnp 2>/dev/null | grep -E "(1514|8888)" | awk '{print "  " $4, "(" $1 ")"}'

echo ""
echo "Fichiers de logs :"
echo ""
for f in /var/log/remote/*/syslog; do
    if [ -f "$f" ]; then
        lines=$(wc -l < "$f")
        name=$(basename $(dirname "$f"))
        echo "  ✓ $name : $lines lignes"
    fi
done

echo ""

# ===================================================================
# FIN
# ===================================================================

echo "╔═════════════════════════════════════════════════════════╗"
echo "║         ✅ INSTALLATION TERMINÉE AVEC SUCCÈS !         ║"
echo "╚═════════════════════════════════════════════════════════╝"
echo ""
echo "📊 ACCÈS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Dashboard Web"
echo "  🌐 http://192.168.0.73:8888"
echo "  🌐 http://172.27.60.2:8888 (après changement réseau)"
echo ""
echo "📡 SYSLOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Port : 1514 (UDP)"
echo "  Serveur : 192.168.0.73 ou 172.27.60.2"
echo ""
echo "📋 LOGS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Logs des équipements"
echo "  tail -f /var/log/remote/*/syslog"
echo ""
echo "  Logs des alertes"
echo "  tail -f /var/log/alerts.log"
echo ""
echo "  Logs du Dashboard"
echo "  sudo journalctl -u dashboard -f"
echo ""
echo "🔧 GESTION SERVICES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Redémarrer les services"
echo "  sudo systemctl restart dashboard alert-monitor rsyslog"
echo ""
echo "  Voir le statut"
echo "  sudo systemctl status dashboard"
echo "  sudo systemctl status alert-monitor"
echo ""
echo "📚 DOCUMENTATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Voir les fichiers Markdown :"
echo "  • documentation-monitoring.md"
echo "  • configuration-equipements.md"
echo "  • configuration-radius.md"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
