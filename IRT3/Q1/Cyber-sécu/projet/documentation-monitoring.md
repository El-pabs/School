# Network Monitoring Dashboard - Documentation Complète

## 📋 Vue d'ensemble

Ce système de monitoring centralisé collecte, analyse et visualise les logs de tous tes équipements réseau (FortiGate, Switch, Routeur) en temps réel.

## 🏗️ Architecture du système

```
┌─────────────────────────────────────────────────────────────────┐
│                     ÉQUIPEMENTS RÉSEAU                          │
│  (FortiGate, Switch, Routeur sur 172.27.60.X)                   │
└────────────────┬────────────────────────────────────────────────┘
                 │ Envoie logs via UDP/1514
                 ↓
┌─────────────────────────────────────────────────────────────────┐
│                   SERVEUR LINUX (192.168.0.73)                  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ RSYSLOG (Port 1514)                                      │  │
│  │ • Reçoit les logs en UDP                                 │  │
│  │ • Trie par équipement                                    │  │
│  │ • Stocke dans /var/log/remote/                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         ↓                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ ALERT MONITOR (Python)                                   │  │
│  │ • Analyse les logs toutes les 10s                        │  │
│  │ • Détecte les erreurs/alertes                            │  │
│  │ • Déclenche les actions (CRITICAL, ERROR, WARNING)       │  │
│  │ • Logs des actions dans /var/log/alerts.log              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         ↓                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ DASHBOARD WEB (Flask, Port 8888)                         │  │
│  │ • Interface visuelle en temps réel                       │  │
│  │ • Affiche les alertes                                    │  │
│  │ • Montre les logs par équipement                         │  │
│  │ • Rafraîchit toutes les 5 secondes                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         ↑                                       │
└────────────────────────────────────────────────────────────────┘
                         │
                 Accès via HTTP
                         │
                 🌐 Navigateur Web
```

## 🔧 Composants principaux

### 1. **Rsyslog** (Service de logs centralisé)
- **Port** : 1514 (UDP)
- **Rôle** : Reçoit les logs de tous les équipements
- **Stockage** : `/var/log/remote/{HOSTNAME}/syslog`
- **Configuration** : `/etc/rsyslog.d/50-network.conf`

**Flux** :
```
FortiGate → UDP 1514 → Rsyslog → /var/log/remote/G2-FRW-AG008-00-P-003/syslog
```

### 2. **Alert Monitor** (Détection des problèmes)
- **Type** : Script Python exécuté en service systemd
- **Fréquence** : Vérification toutes les 10 secondes
- **Logique** :
  - Lit les fichiers logs
  - Détecte les patterns d'erreur (ERROR, BLOCKED, WARNING, etc.)
  - Compare avec l'état précédent
  - Déclenche les actions si changement détecté

**Niveaux d'alerte** :
- 🚨 **CRITICAL** : Erreurs critiques → Action immédiate
- ❌ **ERROR** : Erreurs système → Logging
- ⚠️ **WARNING** : Avertissements → Notification
- ℹ️ **INFO** : Information normale

### 3. **Dashboard Web** (Visualisation)
- **Port** : 8888 (HTTP)
- **Technologie** : Flask (Python)
- **Actualisation** : Toutes les 5 secondes
- **Accès** : `http://192.168.0.73:8888`

**Éléments affichés** :
1. **Banneau d'alertes** en haut (rouge si problèmes)
2. **Statistiques d'alertes** : Compte par type (CRITICAL, ERROR, WARNING, ACTIONS)
3. **Dernières alertes** : Flux des 15 dernières alertes
4. **Panneaux équipements** : 1 par appareil avec :
   - Nom et type
   - Statut global (UP, WARNING, ERROR, CRITICAL, DOWN)
   - Compteurs (CRITICAL, ERROR, WARNING, INFO)
   - Logs bruts (derniers 25 logs)

## 📊 Flux de données

### Exemple 1 : Détection d'une attaque IPS

```
1. FortiGate détecte SQL.Injection
   │
2. Envoie log à 192.168.0.73:1514
   │
3. Rsyslog reçoit et stocke dans /var/log/remote/G2-FRW-AG008-00-P-003/syslog
   │
4. Alert Monitor lit le fichier (toutes les 10s)
   │
5. Voit "blocked" et "SQL.Injection" → Classifie comme ERROR
   │
6. Déclenche remediation : log_alert("[ERROR] Attaque IPS bloquée")
   │
7. Dashboard affiche dans "Dernières alertes"
   │
8. Utilisateur voit immédiatement le problème
```

### Exemple 2 : Récupération d'une interface

```
1. Switch a une interface DOWN
   │
2. Alert Monitor détecte l'erreur → Status = ERROR
   │
3. Affiche dans Dashboard (panneau Switch)
   │
4. Équipement corrige le problème (interface revient UP)
   │
5. Log reçu : "changed state to up" → Classifié comme INFO
   │
6. Alert Monitor détecte le changement de statut
   │
7. log_alert("[STATE CHANGE] Switch: ERROR → UP")
   │
8. Dashboard met à jour automatiquement
```

## 🎯 Statuts et sévérités

### Statut de l'équipement

| Statut | Couleur | Signification |
|--------|---------|---------------|
| **UP** | 🟢 Vert | Tout fonctionne normalement |
| **WARNING** | 🟡 Jaune | Avertissements détectés |
| **ERROR** | 🟠 Orange | Erreurs détectées |
| **CRITICAL** | 🔴 Rouge | Erreurs critiques |
| **DOWN** | ⚫ Noir | Pas de logs reçus |

### Sévérité des logs

| Sévérité | Détection | Exemple |
|----------|-----------|---------|
| **CRITICAL** | Mot-clé : critical, emergency, panic | `OSPF-3-ERRRCV` |
| **ERROR** | Mot-clé : error, blocked, denied, fail | `%INTERFACE-2-ERROR`, `action="blocked"` |
| **WARNING** | Mot-clé : warning, alert, problem | `level="warning"`, `%BGP-3-NOTIFICATION` |
| **INFO** | Tout le reste | `changed state`, logs normaux |

## 📈 Métriques affichées

Pour chaque équipement, le Dashboard affiche 4 compteurs :

- **CRIT** : Nombre de logs CRITICAL
- **ERR** : Nombre de logs ERROR
- **WARN** : Nombre de logs WARNING
- **INFO** : Nombre de logs INFO

## 🔄 Cycle de vie des alertes

```
1. GÉNÉRATION
   └─ Équipement rencontre un problème
      └─ Envoie log à Rsyslog

2. RÉCEPTION
   └─ Rsyslog reçoit sur port 1514
      └─ Stocke dans /var/log/remote/

3. ANALYSE
   └─ Alert Monitor lit toutes les 10s
      └─ Détecte le changement de statut
      └─ Exécute les actions de remediation

4. VISUALISATION
   └─ Dashboard rafraîchit toutes les 5s
      └─ Affiche le problème en temps réel
      └─ Utilisateur voit les alertes

5. RÉSOLUTION
   └─ Équipement corrige le problème
      └─ Envoie log "résolu"
      └─ Alert Monitor détecte la résolution
      └─ Dashboard met à jour l'état
```

## 🚀 Démarrage et arrêt

### Vérifier les services

```bash
# Dashboard
sudo systemctl status dashboard

# Alert Monitor
sudo systemctl status alert-monitor

# Rsyslog
sudo systemctl status rsyslog
```

### Redémarrer les services

```bash
sudo systemctl restart dashboard
sudo systemctl restart alert-monitor
sudo systemctl restart rsyslog
```

### Voir les logs en direct

```bash
# Logs du Dashboard
sudo journalctl -u dashboard -f

# Logs des alertes
tail -f /var/log/alerts.log

# Logs de tous les équipements
tail -f /var/log/remote/*/syslog
```

## 📍 Emplacement des fichiers

```
/etc/rsyslog.d/50-network.conf          Configuration Rsyslog
/etc/systemd/system/dashboard.service   Service Dashboard
/etc/systemd/system/alert-monitor.service  Service Alert Monitor

/opt/dashboard-app.py                   Code Dashboard
/opt/alert-monitor.py                   Code Alert Monitor
/opt/scripts/remediation.sh             Actions de remediation

/var/log/remote/                        Stockage des logs
/var/log/alerts.log                     Logs des alertes détectées
/var/log/remediation.log                Logs des actions exécutées
```

## 🔐 Sécurité

- Les logs sont stockés localement (pas de cloud)
- Rsyslog écoute uniquement sur le port 1514
- Le Dashboard est accessible sans authentification (configurable)
- Recommandation : Placer derrière un firewall/VPN en production

## 📱 Accès

### Immédiatement (192.168.0.73)
```
http://192.168.0.73:8888
```

### Après changement réseau (172.27.60.2)
```
http://172.27.60.2:8888
```

L'IP change mais le système continue de fonctionner identiquement.

## ✅ Checklist post-installation

- [ ] Dashboard accessible via `http://192.168.0.73:8888`
- [ ] Voir les faux logs s'afficher
- [ ] Voir les alertes détectées dans le banneau rouge
- [ ] Services démarrés : dashboard, alert-monitor, rsyslog
- [ ] Ports ouverts : 1514 (UDP), 8888 (TCP)
- [ ] Fichiers de logs présents : `/var/log/remote/*/syslog`
- [ ] Alertes loggées : `/var/log/alerts.log`

