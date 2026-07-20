# Configuration des équipements réseau pour Syslog

## 🎯 Objectif

Configurer chaque équipement (FortiGate, Switch, Routeur) pour envoyer ses logs au serveur centralisé Syslog.

## 📡 Paramètres généraux

| Paramètre | Valeur |
|-----------|--------|
| **Serveur Syslog** | 192.168.0.73 (actuellement) |
| **Port Syslog** | 1514 |
| **Protocole** | UDP |
| **Format** | Standard syslog |

*Après changement réseau, remplacer 192.168.0.73 par 172.27.60.2*

---

## 🔒 Firewall Fortinet (FortiGate)

### Vérification de la licence Logging

D'abord, vérifie que tu as les droits de logging :

```
FortiGate # get system status | grep "Logging"
```

### Configuration en CLI

```
FortiGate # config log syslogd setting
FortiGate (syslogd setting) # set status enable
FortiGate (syslogd setting) # set server 192.168.0.73
FortiGate (syslogd setting) # set port 1514
FortiGate (syslogd setting) # set mode udp
FortiGate (syslogd setting) # set facility local7
FortiGate (syslogd setting) # set priority high
FortiGate (syslogd setting) # set log-alert-objects enable
FortiGate (syslogd setting) # set log-packets disable
FortiGate (syslogd setting) # end
```

### Configuration dans la GUI Fortinet

1. Aller dans **Log & Report → Log Settings → Syslog**
2. Activer **Enable Remote Logging**
3. **Server Address** : `192.168.0.73`
4. **Server Port** : `1514`
5. **Protocol** : UDP
6. **Syslog Facility** : LOCAL7
7. **Log Events** : Sélectionner ce que tu veux logger

### Quels logs envoyer ?

Pour maximum de visibilité, configure :

```
FortiGate (syslogd setting) # config log syslogd filter
FortiGate (filter) # set traffic enable
FortiGate (filter) # set event enable
FortiGate (filter) # set system enable
FortiGate (filter) # set anomaly enable
FortiGate (filter) # set utm enable
FortiGate (filter) # end
```

### Test de connexion

Sur le FortiGate :
```
FortiGate # diagnose log syslogd connection
```

Vérifie que le statut est **connected**.

### Vérifier les logs reçus

Sur le serveur Linux :
```bash
tail -f /var/log/remote/G2-FRW-AG008-00-P-003/syslog
```

Tu devrais voir les logs du FortiGate arriver en direct.

---

## 🔌 Switch Cisco

### Configuration de base

```
Switch# configure terminal
Switch(config)# logging 192.168.0.73
Switch(config)# logging trap notifications
Switch(config)# no logging console
Switch(config)# exit
```

### Configuration complète (recommandée)

```
Switch# configure terminal
Switch(config)# logging host 192.168.0.73 transport udp port 1514
Switch(config)# logging source-interface Vlan 60
Switch(config)# logging trap warnings
Switch(config)# logging facility local7
Switch(config)# exit
```

### Vérifier la configuration

```
Switch# show logging
```

Tu devrais voir :
- Syslog logging: enabled
- Facility: local7
- Server address(es): 192.168.0.73
- Logging to 192.168.0.73 (192.168.0.73), 0 messages logged

### Vérifier les logs reçus

Sur le serveur Linux :
```bash
tail -f /var/log/remote/G2-SWT-AG009-00-P-201/syslog
```

### Forcer un test

Pour tester manuellement :
```
Switch# send log-message "TEST MESSAGE FROM SWITCH"
```

Le message apparaîtra immédiatement dans `/var/log/remote/G2-SWT-AG009-00-P-201/syslog`

### Logs à monitorer

Les logs intéressants incluent :

- `%LINK-3-UPDOWN` : Changement d'état d'interface
- `%INTERFACE-2-ERROR` : Erreurs d'interface
- `%STP-4-BLOCK_PORT_NUM` : Changements STP
- `%VLAN-3-*` : Problèmes VLAN
- `%SPANNING_TREE_*` : Problèmes Spanning Tree

---

## 🌐 Routeur Cisco

### Configuration de base

```
Router# configure terminal
Router(config)# logging host 192.168.0.73
Router(config)# logging trap warnings
Router(config)# exit
```

### Configuration complète (recommandée)

```
Router# configure terminal
Router(config)# logging host 192.168.0.73 transport udp port 1514
Router(config)# logging source-interface GigabitEthernet0/0/0
Router(config)# logging trap warnings
Router(config)# logging facility local7
Router(config)# no logging console
Router(config)# exit
```

### Vérifier la configuration

```
Router# show logging
```

### Vérifier les logs reçus

Sur le serveur Linux :
```bash
tail -f /var/log/remote/G2-RTR-AG008-00-P-002/syslog
```

### Forcer un test

```
Router# send log "TEST MESSAGE FROM ROUTER"
```

### Logs à monitorer

Les logs critiques incluent :

- `%OSPF-5-*` : Changements d'adjacence OSPF
- `%BGP-3-NOTIFICATION` : Perte de session BGP
- `%IP_EIGRP-5-*` : Changements EIGRP
- `%LINK-3-UPDOWN` : Changements d'interface
- `%CRYPTO-4-*` : Problèmes de chiffrement

---

## 🔍 Dépannage - Logs non reçus

### Vérification réseau

1. **Vérifier la connectivité IP**

Sur le routeur/switch :
```
Router# ping 192.168.0.73
```

2. **Vérifier le port UDP**

Sur le serveur Linux :
```bash
sudo ss -tulnp | grep 1514
```

Doit afficher :
```
udp    LISTEN  0  0  0.0.0.0:1514  0.0.0.0:*  /opt/dashboard-app.py
```

3. **Voir si les paquets arrivent**

Sur le serveur Linux, utiliser tcpdump :
```bash
sudo tcpdump -i any -n udp port 1514
```

### Vérification sur l'équipement

1. **FortiGate** : Vérifier que le statut est "connected"
```
FortiGate # diagnose log syslogd connection
```

2. **Switch/Routeur** : Vérifier la configuration
```
Switch# show logging
```

3. **Firewall bloquant les logs ?**

Vérifier que rien ne bloque le port UDP 1514 entre l'équipement et le serveur.

### Vérification des dossiers

```bash
# Les dossiers existent-ils ?
ls -la /var/log/remote/

# Rsyslog est-il actif ?
sudo systemctl status rsyslog

# Voir les erreurs rsyslog
sudo journalctl -u rsyslog -n 50
```

---

## ✅ Checklist de configuration

### FortiGate
- [ ] Syslog activé en CLI ou GUI
- [ ] Server : 192.168.0.73
- [ ] Port : 1514
- [ ] Protocol : UDP
- [ ] Logs reçus dans `/var/log/remote/G2-FRW-AG008-00-P-003/syslog`

### Switch
- [ ] Logging host configuré
- [ ] Adresse : 192.168.0.73
- [ ] Port : 1514
- [ ] Trap level : warnings
- [ ] Logs reçus dans `/var/log/remote/G2-SWT-AG009-00-P-201/syslog`

### Routeur
- [ ] Logging host configuré
- [ ] Adresse : 192.168.0.73
- [ ] Port : 1514
- [ ] Trap level : warnings
- [ ] Logs reçus dans `/var/log/remote/G2-RTR-AG008-00-P-002/syslog`

### Serveur
- [ ] Rsyslog actif : `sudo systemctl status rsyslog`
- [ ] Port 1514 ouvert : `sudo ss -tulnp | grep 1514`
- [ ] Dossiers créés : `ls /var/log/remote/`
- [ ] Dashboard affiche les logs : `http://192.168.0.73:8888`

---

## 📞 Support

Si les logs n'arrivent pas :

1. Vérifier la connectivité ping vers le serveur
2. Vérifier que port 1514/UDP n'est pas bloqué par un firewall intermédiaire
3. Vérifier dans `/var/log/syslog` ou `journalctl -u rsyslog` les erreurs
4. Relancer rsyslog : `sudo systemctl restart rsyslog`
5. Tester manuellement un message de log

