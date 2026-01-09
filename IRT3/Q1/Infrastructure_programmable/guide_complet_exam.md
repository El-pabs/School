# Guide Complet : Docker, Kubernetes, Terraform, GitHub Actions
## Pour Réussir N'importe Quelle Question d'Examen

---

## TABLE DES MATIÈRES

1. [DOCKER](#docker)
2. [KUBERNETES](#kubernetes)
3. [TERRAFORM](#terraform)
4. [GITHUB ACTIONS](#github-actions)
5. [Concepts Transversaux](#concepts-transversaux)

---

# DOCKER

## 1. Principes Fondamentaux

### Qu'est-ce que Docker ?

Docker est un **système de virtualisation légère** basé sur des **conteneurs**. Contrairement à une machine virtuelle complète (qui virtualise le kernel, les drivers, etc.), Docker partage le kernel du système d'exploitation hôte et n'isole que l'application et ses dépendances.

**Analogie utile :** 
- Une **VM** = un conteneur de transport complet avec moteur inclus
- Un **conteneur Docker** = une boîte de transport réutilisable avec uniquement vos marchandises

### Architecture Docker

```
┌─────────────────────────────────────────────────────┐
│                  Système d'Exploitation              │
│                   (Linux Kernel)                      │
├─────────────────────────────────────────────────────┤
│              Docker Daemon (dockerd)                 │
│         (Gère les conteneurs et images)             │
├─────────────────────────────────────────────────────┤
│  Conteneur 1  │  Conteneur 2  │  Conteneur 3        │
│ (App + deps)  │ (App + deps)  │ (App + deps)        │
└─────────────────────────────────────────────────────┘
```

### Composants Clés

**1. Image Docker**
- Snapshot/modèle immuable contenant : code, runtime, dépendances, système de fichiers
- Construite en couches (chaque instruction Dockerfile = une couche)
- Stockée dans un registre (Docker Hub, ECR, GCR, etc.)

**2. Conteneur Docker**
- Instance **exécutable** d'une image
- Couche supplémentaire d'écriture (read-write) au-dessus des couches image (read-only)
- Peut être arrêté, redémarré, supprimé

**3. Docker Daemon (dockerd)**
- Service système qui gère : création de conteneurs, gestion des images, réseaux, volumes
- Écoute les commandes via socket Unix

**4. Docker Client**
- CLI que vous utilisez (`docker run`, `docker build`, etc.)
- Envoie les commandes au Daemon via l'API REST

**5. Registre Docker**
- Dépôt centralisé d'images (Docker Hub, AWS ECR, Google GCR, Azure ACR)
- `docker push` = envoyer une image
- `docker pull` = télécharger une image

---

## 2. Cycle de Vie des Images

### Construction d'une Image (Dockerfile)

**Flux Dockerfile :**
```
Dockerfile
   ↓
Docker Build (lit le Dockerfile ligne par ligne)
   ↓
Pour CHAQUE instruction (FROM, RUN, COPY, etc.) :
  ├─ Crée un conteneur temporaire
  ├─ Exécute l'instruction
  ├─ Crée une image intermédiaire (couche)
  └─ Supprime le conteneur temporaire
   ↓
Image finale (unification de toutes les couches)
```

**Structure Dockerfile typique :**

```dockerfile
# 1. Image de base
FROM ubuntu:latest

# 2. Définir des variables d'environnement
ENV APP_HOME=/app

# 3. Installer les dépendances (chaque RUN = une couche)
RUN apt-get update -y && \
    apt-get install -y python3 pip && \
    rm -rf /var/lib/apt/lists/*

# 4. Définir le répertoire de travail
WORKDIR ${APP_HOME}

# 5. Copier les fichiers du host vers le conteneur
COPY . .

# 6. Installer les dépendances Python
RUN pip install -r requirements.txt

# 7. Exposer le port (documentation, ne crée pas vraiment le mappage)
EXPOSE 5000

# 8. Commande par défaut au démarrage
CMD ["python3", "app.py"]
```

**Concepts importants :**
- **FROM** : toujours première ligne, définit l'image de base
- **RUN** : exécute des commandes au build (création couche)
- **COPY/ADD** : copie des fichiers du host vers le conteneur
- **WORKDIR** : change le répertoire courant (comme `cd`)
- **ENV** : définit variables d'environnement
- **EXPOSE** : documente quels ports le conteneur utilise (ne mappe pas automatiquement)
- **CMD** : commande par défaut au lancement du conteneur
- **ENTRYPOINT** : point d'entrée figé (plus difficile à surcharger que CMD)

### Couches et Cache

**Chaque instruction RUN crée une couche :**
```
Instruction 1 → Couche 1 (image intermédiaire)
Instruction 2 → Couche 2 (image intermédiaire)
Instruction 3 → Couche 3 (image finale)
```

**Cache :** Si vous rebuildez et qu'une instruction n'a pas changé, Docker utilise le cache (très rapide). Pour éviter le cache : `docker build --no-cache`.

**Optimisation :**
```dockerfile
# ❌ MAUVAIS (3 couches)
RUN apt-get update
RUN apt-get install nginx
RUN rm -rf /var/lib/apt/lists/*

# ✅ BON (1 couche, utilise les couches précédentes en cache)
RUN apt-get update && \
    apt-get install nginx && \
    rm -rf /var/lib/apt/lists/*
```

---

## 3. Commandes Docker Essentielles

### Images

```bash
# Construire une image
docker build -t nom_utilisateur/nom_app:tag .
docker build -t robin/myapp:1.0 .

# Lister les images
docker images

# Inspecter une image (voir couches, ENV, CMD, etc.)
docker inspect robin/myapp:1.0

# Supprimer une image
docker rmi robin/myapp:1.0  # par tag
docker rmi <SHA>            # par ID

# Tagger une image existante
docker tag robin/myapp:1.0 robin/myapp:latest

# Pousser vers un registre
docker push robin/myapp:1.0

# Puller depuis un registre
docker pull nginx:latest
```

### Conteneurs

```bash
# Lancer un conteneur
docker run [OPTIONS] IMAGE:TAG [COMMAND]

# Options courantes :
# -d           : Mode détaché (background)
# -it          : Mode interactif + terminal pseudo
# --rm         : Supprimer le conteneur à l'arrêt
# -p 8080:80   : Mapper port 8080 (host) → 80 (conteneur)
# -P           : Mapper tous les ports exposés automatiquement
# --name nom   : Nommer le conteneur
# -e VAR=val   : Passer une variable d'environnement
# -v /h:/c     : Monter un volume (host:conteneur)
# --network    : Connecter à un réseau

# Exemples :
docker run -d --name webserver -p 8080:80 nginx
docker run -it ubuntu bash
docker run --rm alpine sleep 10

# Lister les conteneurs actifs
docker ps

# Lister TOUS les conteneurs (actifs + arrêtés)
docker ps -a

# Voir les logs
docker logs nom_conteneur
docker logs -f nom_conteneur  # suivi en temps réel

# Exécuter une commande dans un conteneur actif
docker exec -it nom_conteneur bash

# Arrêter un conteneur
docker stop nom_conteneur

# Relancer un conteneur arrêté
docker start nom_conteneur

# Supprimer un conteneur
docker rm nom_conteneur

# Inspecter un conteneur
docker inspect nom_conteneur
```

---

## 4. Volumes et Réseaux Docker

### Volumes

Les volumes permettent de persister les données au-delà de la vie du conteneur.

**Types :**

1. **Named Volume** (managé par Docker)
```bash
docker volume create mon-volume
docker run -v mon-volume:/data nginx
```

2. **Bind Mount** (dossier du host mappé)
```bash
docker run -v /chemin/host:/chemin/conteneur nginx
```

3. **tmpfs** (en RAM, volatile)
```bash
docker run --tmpfs /data nginx
```

### Réseaux Docker

Les réseaux permettent aux conteneurs de communiquer.

**Types :**
- **bridge** : réseau privé (défaut, conteneurs isolés les uns des autres)
- **host** : conteneur partage le réseau de l'hôte
- **none** : pas de réseau

**Commandes :**
```bash
# Créer un réseau
docker network create mon-reseau

# Lister les réseaux
docker network ls

# Connecter un conteneur à un réseau
docker run --network mon-reseau nginx

# Conteneurs sur le même réseau peuvent se parler par nom
# Ex: curl http://web1 (si web1 est le nom du conteneur)
```

---

## 5. Docker Compose

Docker Compose permet de définir et lancer plusieurs conteneurs avec un seul fichier YAML.

**Fichier docker-compose.yml :**

```yaml
version: '3.8'

services:
  # Service 1 : Base de données
  db:
    image: postgres:13
    container_name: mydb
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: myapp
    ports:
      - "5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - app-network

  # Service 2 : Application web
  web:
    build: .
    image: myapp:1.0
    container_name: myapp
    depends_on:
      - db
    environment:
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: admin
    ports:
      - "8000:5000"
    volumes:
      - ./app:/app
    networks:
      - app-network
    restart: unless-stopped

  # Service 3 : Nginx (reverse proxy/load balancer)
  nginx:
    image: nginx:alpine
    container_name: nginx-lb
    depends_on:
      - web
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    networks:
      - app-network

# Volumes nommés (persistants)
volumes:
  db_data:

# Réseaux
networks:
  app-network:
    driver: bridge
```

**Commandes Docker Compose :**

```bash
# Lancer tous les services
docker-compose up

# Lancer en arrière-plan
docker-compose up -d

# Arrêter tous les services
docker-compose down

# Voir les logs
docker-compose logs -f

# Lister les services actifs
docker-compose ps

# Exécuter une commande dans un service
docker-compose exec db psql -U admin -d myapp
```

---

## 6. Cas d'Usage Courants (Examen)

### Comment construire et pousser une image vers Docker Hub ?

```bash
# 1. Créer le Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
EOF

# 2. Builder l'image localement
docker build -t robin/myapp:1.0 .

# 3. Se logger à Docker Hub
docker login

# 4. Pousser l'image
docker push robin/myapp:1.0

# 5. L'image est maintenant disponible pour toute personne
# docker pull robin/myapp:1.0
```

### Comment transformer un conteneur en image (docker commit) ?

```bash
# 1. Lancer un conteneur
docker run -it ubuntu bash

# 2. Dans le conteneur, installer un paquet
apt-get update && apt-get install -y curl

# 3. Sortir du conteneur (Ctrl+D ou exit)

# 4. Voir le conteneur arrêté
docker ps -a

# 5. Créer une nouvelle image à partir du conteneur
docker commit <CONTAINER_ID> robin/ubuntu-with-curl:1.0

# 6. Vérifier la nouvelle image
docker images | grep curl
```

### Comment debugger un conteneur qui plante ?

```bash
# 1. Voir les logs
docker logs nom_conteneur

# 2. Si le conteneur est en crash loop, garder les logs
docker logs -f nom_conteneur

# 3. Lancer le conteneur en mode interactif (override CMD)
docker run -it image_name bash

# 4. Inspecter les variables d'environnement
docker inspect nom_conteneur | grep -A 20 Env

# 5. Vérifier les ressources CPU/RAM
docker stats nom_conteneur
```

---

# KUBERNETES

## 1. Principes Fondamentaux

### Qu'est-ce que Kubernetes ?

Kubernetes est un **orchestrateur de conteneurs** (principalement Docker). Il automatise le déploiement, l'escalade et la gestion des applications conteneurisées sur un **cluster** (ensemble de machines).

**Kubernetes résout :**
- Où placer les conteneurs sur quel nœud ?
- Comment scaler automatiquement (ajouter/retirer de répliques) ?
- Comment faire de la mise à jour sans downtime ?
- Comment réparer les conteneurs qui plantent ?
- Comment load-balancer le trafic ?

### Architecture Kubernetes

```
┌─────────────────────────────────────────┐
│       Kubernetes Cluster                │
├──────────────┬──────────────┬───────────┤
│  Control     │  Control     │  Control  │  (Plane de Contrôle)
│  Plane Node  │  Plane Node  │  Plane Node
├──────────────┼──────────────┼───────────┤
│              │              │           │
│  Worker 1    │  Worker 2    │  Worker 3 │  (Nœuds)
│  (kubelet)   │  (kubelet)   │ (kubelet) │
│  (containers)│  (containers)│(containers)
│              │              │           │
└──────────────┴──────────────┴───────────┘
```

### Composants du Control Plane

**API Server** : Point d'entrée principal (reçoit tous les `kubectl` commands)

**etcd** : Base de données clé-valeur qui stocke l'état du cluster

**Scheduler** : Décide quel nœud placer un pod sur

**Controller Manager** : Boucle de réconciliation (assure que l'état réel = l'état désiré)

**kubelet** (sur chaque nœud) : Agent qui gère les pods sur le nœud

---

## 2. Objets Kubernetes Essentiels

### Pod

**Le plus petit objet déployable** = une ou plusieurs conteneurs partageant le réseau (généralement 1 conteneur par pod).

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  namespace: default
spec:
  containers:
  - name: web
    image: nginx:latest
    ports:
    - containerPort: 80
```

**Points clés :**
- Les pods sont éphémères (peuvent être supprimés/recréés)
- Ne jamais créer des pods directement en production → utilisez des Deployments
- Un pod a une IP unique dans le cluster

### Deployment

**Contrôleur qui manage la création/suppression de pods** pour assurer le nombre de répliques désiré.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 3  # Créer 3 pods
  selector:
    matchLabels:
      app: web
  template:  # Template pour créer les pods
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.19
        ports:
        - containerPort: 80
```

**Commandes courantes :**
```bash
# Appliquer le deployment
kubectl apply -f deployment.yaml

# Voir les deployments
kubectl get deployments

# Voir les pods créés par le deployment
kubectl get pods

# Scaler le nombre de répliques
kubectl scale deployment web-deployment --replicas=5

# Voir les détails
kubectl describe deployment web-deployment
```

### Service

**Expose un Deployment** avec une adresse IP stable (car les pods ont des IPs éphémères).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: ClusterIP  # ou NodePort, ou LoadBalancer
  selector:
    app: web  # Sélectionne tous les pods avec label app=web
  ports:
  - protocol: TCP
    port: 80           # Port du service
    targetPort: 80     # Port du pod
```

**Types de Service :**

1. **ClusterIP** (défaut) : Accès interne au cluster uniquement
   ```
   kubectl exec -it autre-pod -- curl http://web-service
   ```

2. **NodePort** : Accès externe via IP du nœud + port
   ```
   kubectl get svc
   # Service exposé sur http://<NodeIP>:30000
   ```

3. **LoadBalancer** : Accès externe via load balancer cloud (AWS ELB, GCP LB, etc.)
   ```
   kubectl get svc
   # Service exposé sur http://<External-IP>
   ```

### ConfigMap

Stocke des données non-sensibles (configurations, fichiers).

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.properties: |
    DEBUG=true
    LOG_LEVEL=INFO
  database.yml: |
    host: db.default.svc.cluster.local
    port: 5432
```

Utilisation dans un Pod :
```yaml
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: LOG_LEVEL
    volumeMounts:
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config
```

### Secret

Stocke des données sensibles (mots de passe, tokens, clés).

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
stringData:
  username: admin
  password: supersecret123
```

Utilisation :
```yaml
spec:
  containers:
  - name: app
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
```

### Ingress

Route le trafic HTTP/HTTPS externe vers les services internes.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - host: myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

---

## 3. Namespace

Permettent de diviser le cluster en **compartiments logiques**.

```bash
# Créer un namespace
kubectl create namespace production

# Lister les namespaces
kubectl get namespaces

# Voir les pods dans un namespace spécifique
kubectl get pods -n production

# Appliquer une ressource dans un namespace spécifique
kubectl apply -f deployment.yaml -n production

# Changer le namespace par défaut
kubectl config set-context --current --namespace=production

# Voir toutes les ressources de tous les namespaces
kubectl get all --all-namespaces
```

---

## 4. Commandes kubectl Essentielles

```bash
# Voir l'état du cluster
kubectl cluster-info
kubectl get nodes

# Pods
kubectl get pods
kubectl get pods -o wide  # Plus de détails
kubectl describe pod nom-pod
kubectl logs pod-name
kubectl logs -f pod-name  # Suivi temps réel
kubectl exec -it pod-name -- bash  # Entrer dans le pod

# Deployments
kubectl get deployments
kubectl describe deployment nom-deployment
kubectl set image deployment/nom-deployment app=newimage:tag  # Mise à jour d'image
kubectl rollout history deployment/nom-deployment  # Voir l'historique des déploiements
kubectl rollout undo deployment/nom-deployment  # Revenir à la version précédente

# Services
kubectl get services
kubectl describe service nom-service
kubectl port-forward service/nom-service 8080:80  # Mapper un port local

# ConfigMap / Secrets
kubectl get configmaps
kubectl get secrets
kubectl describe configmap app-config

# Apply / Delete
kubectl apply -f fichier.yaml
kubectl delete -f fichier.yaml
kubectl delete pod nom-pod
kubectl delete deployment nom-deployment

# Générer des manifests (utile pour l'examen !)
kubectl create deployment web --image=nginx --dry-run=client -o yaml > deployment.yaml
```

---

## 5. Déploiements et Mises à Jour

### Stratégies de Déploiement

**1. Rolling Update (défaut)**
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Pods supplémentaires pendant la mise à jour
      maxUnavailable: 1  # Pods qui peuvent être indisponibles
```
- Remplace progressivement les pods
- Aucun downtime
- Plus lent

**2. Recreate**
```yaml
spec:
  strategy:
    type: Recreate
```
- Supprime tous les anciens pods, crée les nouveaux
- Downtime possible
- Plus rapide

### Probes (Health Checks)

```yaml
spec:
  containers:
  - name: app
    image: myapp:1.0
    
    # Readiness : le pod est-il prêt à recevoir du trafic ?
    readinessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 5
    
    # Liveness : le pod est-il vivant ?
    livenessProbe:
      httpGet:
        path: /alive
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 10
```

---

## 6. Cas d'Usage Courants (Examen)

### Comment déployer une application sur Kubernetes ?

```bash
# 1. Créer le manifeste deployment
cat > deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: robin/myapp:1.0
        ports:
        - containerPort: 5000
EOF

# 2. Créer le manifeste service
cat > service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 5000
EOF

# 3. Appliquer les manifestes
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 4. Vérifier le déploiement
kubectl get pods
kubectl get services
```

### Comment scaler une application ?

```bash
# Método 1 : Imperativement
kubectl scale deployment myapp --replicas=10

# Método 2 : Editer le deployment
kubectl edit deployment myapp
# (Changer replicas: 3 → replicas: 10)

# Método 3 : Utiliser un HorizontalPodAutoscaler
kubectl autoscale deployment myapp --min=2 --max=10 --cpu-percent=50
```

### Comment mettre à jour une image sans downtime ?

```bash
# Mettre à jour l'image (rolling update automatique)
kubectl set image deployment/myapp app=robin/myapp:2.0

# Voir le déploiement en cours
kubectl rollout status deployment/myapp

# Voir l'historique des déploiements
kubectl rollout history deployment/myapp

# Revenir à la version précédente
kubectl rollout undo deployment/myapp
```

### Comment déboguer un pod qui ne démarre pas ?

```bash
# 1. Voir les logs
kubectl logs pod-name

# 2. Voir les évènements
kubectl describe pod pod-name

# 3. Vérifier l'image existe et est correcte
kubectl get pod pod-name -o yaml | grep image

# 4. Lancer un conteneur pour tester l'image localement
docker run -it robin/myapp:1.0 bash

# 5. Vérifier le port du conteneur
docker inspect <CONTAINER_ID> | grep ExposedPorts
```

### Comment accéder à une base de données Postgres depuis Kubernetes ?

```yaml
# 1. Déployer Postgres
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432

---
# 2. L'app peut maintenant accéder à la DB
# HOST: postgres-service
# PORT: 5432
# PASSWORD: (depuis le secret)
```

### Comment entrer dans un pod pour déboguer ?

```bash
# Accéder au shell du pod
kubectl exec -it pod-name -- bash

# Vérifier les variables d'environnement
kubectl exec pod-name -- env

# Voir les fichiers de configuration
kubectl exec pod-name -- cat /etc/config/app.conf

# Vérifier la connectivité réseau
kubectl exec pod-name -- curl http://autre-service:80
```

---

# TERRAFORM

## 1. Principes Fondamentaux

### Qu'est-ce que Terraform ?

Terraform est un outil **Infrastructure-as-Code (IaC)** qui permet de définir, prévisualiser et déployer une infrastructure cloud (AWS, GCP, Azure, Kubernetes, etc.) à partir de fichiers de configuration déclaratifs (HCL).

**Avantages :**
- Infrastructure versionnable (Git)
- Reproductible à l'identique
- Destruction/modification facile
- Collaboration d'équipe
- Historique complet des changements

### Concepts Clés

**Provider** : Connecteur vers une plateforme cloud (AWS, GCP, etc.)

**Resource** : Objet à créer/gérer (instance EC2, S3 bucket, RDS, etc.)

**Variable** : Paramètre d'entrée (réutilisable, configurable)

**Output** : Valeur de sortie (ex: IP de l'instance, URL du load balancer)

**State** : Fichier qui track l'état réel de l'infrastructure déployée

**Module** : Collection réutilisable de ressources

---

## 2. Fichiers Terraform Essentiels

### `main.tf` - Les ressources

C'est le cœur, où vous définissez tout ce que vous voulez créer.

```hcl
# 1. Déclarer le provider AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 2. Créer une VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# 3. Créer des subnets publics
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet-1"
  }
}

# 4. Créer une internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# 5. Créer une route table publique
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# 6. Associer le subnet à la route table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# 7. Créer une instance EC2
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(file("${path.module}/user_data.sh"))

  tags = {
    Name = "web-server"
  }
}

# 8. Créer un groupe de sécurité
resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 9. Créer un RDS Database
resource "aws_db_instance" "main" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "13.7"
  instance_class       = "db.t3.micro"
  db_name              = "myappdb"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  skip_final_snapshot  = true

  tags = {
    Name = "main-db"
  }
}

# 10. Load Balancer
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}
```

### `variables.tf` - Les paramètres

Définit les variables acceptées (type, défaut, description).

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "db_username" {
  description = "Database admin username"
  type        = string
  sensitive   = true  # Ne pas afficher en output
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### `terraform.tfvars` - Les valeurs

Donne les valeurs réelles aux variables (chargé automatiquement).

```hcl
aws_region   = "us-east-1"
instance_type = "t2.micro"
environment  = "dev"
```

### `secrets.tfvars` - Valeurs sensibles

Fichier SÉPARÉ pour les secrets (jamais commité sur Git).

```hcl
db_username = "admin"
db_password = "SuperSecurePassword123!"
```

À utiliser :
```bash
terraform plan -var-file="secrets.tfvars"
```

### `outputs.tf` - Les résultats

Ce qui Terraform affiche à la fin.

```hcl
output "instance_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}
```

### `data.tf` - Récupérer des données existantes

```hcl
# Récupérer la dernière AMI Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}
```

### `locals.tf` - Variables locales (optionnel)

```hcl
locals {
  common_tags = {
    Project     = "MyProject"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  name_prefix = "${var.project_name}-${var.environment}"
}

# Utilisation :
# tags = local.common_tags
# name = local.name_prefix
```

### `.terraform.lock.hcl` - Version Lock

Fichier généré automatiquement, garantit les mêmes versions de providers pour l'équipe.

**Ne pas modifier manuellement !**

### `terraform.tfstate` - État du cluster

Fichier qui track l'état réel de l'infrastructure. **JAMAIS modifier manuellement.**

```json
{
  "version": 4,
  "terraform_version": "1.6.0",
  "serial": 42,
  "lineage": "abc123...",
  "outputs": {},
  "resources": [
    {
      "type": "aws_instance",
      "name": "web",
      "instances": [...]
    }
  ]
}
```

---

## 3. Workflow Terraform

### Initialiser un projet

```bash
# Télécharger les providers, préparer le working directory
terraform init
```

### Planifier les changements

```bash
# Voir EXACTEMENT ce qui va être créé/modifié/supprimé
terraform plan

# Sauvegarder le plan dans un fichier (recommandé)
terraform plan -out=tfplan

# Spécifier un fichier de variables
terraform plan -var-file="secrets.tfvars"
```

### Appliquer les changements

```bash
# Créer/modifier l'infrastructure
terraform apply

# Appliquer en utilisant un plan pré-enregistré
terraform apply tfplan

# Auto-approuver sans demande de confirmation (risqué !)
terraform apply -auto-approve
```

### Détruire l'infrastructure

```bash
# Supprimer toutes les ressources
terraform destroy

# Auto-approuver la destruction
terraform destroy -auto-approve
```

### Autres commandes utiles

```bash
# Voir l'état actuel
terraform state list
terraform state show aws_instance.web

# Voir la configuration de la ressource
terraform show

# Formatter le code HCL
terraform fmt -recursive

# Valider la syntaxe
terraform validate

# Voir les graphiques de dépendances (utile !)
terraform graph
```

---

## 4. Backend State

Par défaut, Terraform stocke l'état **localement** (`terraform.tfstate`). Pour la collaboration d'équipe, utiliser un **remote backend**.

### Configurer S3 comme backend

Dans `main.tf` ou `backend.tf` :

```hcl
terraform {
  backend "s3" {
    bucket         = "mon-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

Ou passer les paramètres au `terraform init` :

```bash
terraform init \
  -backend-config="bucket=mon-terraform-state" \
  -backend-config="key=prod/terraform.tfstate" \
  -backend-config="region=us-east-1"
```

**Avantages :**
- État partagé entre les membres de l'équipe
- Locking (évite les conflits)
- Chiffrement automatique
- Historique des versions

---

## 5. Cas d'Usage Courants (Examen)

### Comment créer une infrastructure EC2 + RDS ?

```hcl
# 1. VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# 2. Subnets
resource "aws_subnet" "app_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "db_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# 3. Groupe de sécurité pour l'app
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Groupe de sécurité pour la DB
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Instance EC2
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.app_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              EOF
  )
}

# 6. Sous-groupe de subnets pour RDS
resource "aws_db_subnet_group" "main" {
  subnet_ids = [aws_subnet.db_subnet.id, aws_subnet.app_subnet.id]
}

# 7. Instance RDS
resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "13.7"
  instance_class         = "db.t3.micro"
  db_name                = "myappdb"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
}

# Outputs
output "app_public_ip" {
  value = aws_instance.app.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}
```

### Comment scaler les ressources (modifier le Terraform existant) ?

```bash
# Avant : instance_type = "t2.micro"
# Après : instance_type = "t2.small"

# 1. Modifier le fichier tfvars ou main.tf
terraform plan  # Voir les changements

# 2. Terraform va arrêter l'instance, la modifier, la redémarrer
terraform apply
```

### Comment détruire une ressource spécifique ?

```bash
# Supprimer UNIQUEMENT l'instance EC2
terraform destroy -target aws_instance.app

# Supprimer plusieurs ressources
terraform destroy -target aws_instance.app -target aws_db_instance.postgres
```

### Comment utiliser les variables sensibles de manière sécurisée ?

```bash
# Ne JAMAIS commiter secrets.tfvars sur Git !

# 1. Créer .gitignore
echo "secrets.tfvars" >> .gitignore

# 2. Créer secrets.tfvars localement
cat > secrets.tfvars << 'EOF'
db_username = "admin"
db_password = "SuperSecure123!"
EOF

# 3. Utiliser lors du plan/apply
terraform plan -var-file="secrets.tfvars"
terraform apply -var-file="secrets.tfvars"
```

### Comment importer une ressource existante dans Terraform ?

Si vous avez créé une instance EC2 manuellement dans AWS et voulez la gérer via Terraform :

```bash
# 1. Ajouter la ressource au main.tf (sans attributs)
# resource "aws_instance" "imported_app" { }

# 2. Importer
terraform import aws_instance.imported_app i-0c123456789abcdef

# 3. Voir ce que Terraform a importé
terraform state show aws_instance.imported_app

# 4. Remplir les attributs dans main.tf
# terraform fmt et terraform validate
```

---

# GITHUB ACTIONS

## 1. Principes Fondamentaux

### Qu'est-ce que GitHub Actions ?

GitHub Actions est une plateforme d'**automatisation CI/CD** intégrée à GitHub qui exécute des workflows en réaction à des évènements Git (push, pull request, schedule, etc.).

**Cas d'usage courants :**
- Builder et tester du code à chaque commit
- Construire des images Docker et les pousser vers un registre
- Déployer sur Kubernetes/AWS/GCP
- Exécuter des linters, tests, analyses de sécurité
- Publier des artefacts (releases)

---

## 2. Concepts Clés

### Workflow

Fichier YAML (`.github/workflows/`) qui décrit le processus automatisé.

### Event (Trigger)

Ce qui déclenche le workflow :
- `push` : code poussé vers une branche
- `pull_request` : pull request créée/mise à jour
- `schedule` : selon un cron
- `workflow_dispatch` : déclenché manuellement depuis l'interface
- `release` : release créée

### Job

Section du workflow avec plusieurs étapes (steps).

### Step

Commande ou action à exécuter.

### Action

Code réutilisable fourni par GitHub ou la communauté.

---

## 3. Anatomie d'un Workflow

```yaml
name: CI/CD Pipeline

# Triggers
on:
  push:
    branches: [main, develop]
    paths:
      - 'app/**'
      - 'Dockerfile'
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * *'  # 2h du matin tous les jours
  workflow_dispatch:      # Manuel

# Variables d'environnement globales
env:
  REGISTRY: docker.io
  IMAGE_NAME: robin/myapp

# Jobs
jobs:
  # Job 1 : Test
  test:
    runs-on: ubuntu-latest  # Machine où exécuter le job
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: 3.9
      
      - name: Install dependencies
        run: pip install -r requirements.txt
      
      - name: Run tests
        run: pytest tests/

  # Job 2 : Build and Push Docker Image
  build:
    needs: test  # Dépend du job "test" (n'exécute que si test réussit)
    runs-on: ubuntu-latest
    
    permissions:
      contents: read
      packages: write
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
      
      - name: Image digest
        run: echo ${{ steps.build.outputs.digest }}

  # Job 3 : Deploy
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'  # Déployer uniquement sur main
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/myapp \
            app=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
        env:
          KUBECONFIG: ${{ secrets.KUBE_CONFIG }}
```

---

## 4. Secrets et Contextes

### Secrets

Valeurs sensibles stockées dans GitHub (passwords, tokens, clés API).

Définir un secret :
1. GitHub → Settings → Secrets and variables → Actions
2. New repository secret
3. Nom : `DOCKER_PASSWORD`, Valeur : `mon_password`

Utiliser :
```yaml
- name: Login
  uses: docker/login-action@v3
  with:
    password: ${{ secrets.DOCKER_PASSWORD }}
```

### Contextes

Informations du workflow en cours d'exécution :

```yaml
- name: Show context
  run: |
    echo "Branch: ${{ github.ref }}"
    echo "Commit SHA: ${{ github.sha }}"
    echo "Actor: ${{ github.actor }}"
    echo "Event: ${{ github.event_name }}"
```

---

## 5. Commandes et Patterns Courants

### Pattern : Build et Push Docker automatiquement

```yaml
name: Docker Build and Push

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/myapp:latest
            ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }}
```

### Pattern : Tester + Construire + Déployer

```yaml
name: Full CI/CD

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: 3.9
      - run: pip install pytest
      - run: pytest

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .
      
      - name: Deploy with kubectl
        run: |
          kubectl set image deployment/myapp \
            app=myapp:${{ github.sha }}
        env:
          KUBECONFIG: ${{ secrets.KUBE_CONFIG }}
```

### Pattern : Terraform Plan/Apply

```yaml
name: Terraform

on:
  push:
    branches: [main]
    paths:
      - 'terraform/**'
  pull_request:

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.0
      
      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Plan
        run: terraform plan -out=tfplan
      
      - name: Terraform Apply
        if: github.event_name == 'push'
        run: terraform apply -auto-approve tfplan
```

### Pattern : Mettre à jour une version dans Git après le build

```yaml
- name: Commit updated deployment
  run: |
    git config user.name "github-actions"
    git config user.email "github-actions@github.com"
    git add deployment.yaml
    git commit -m "chore: update image to ${{ github.sha }} [skip ci]"
    git push
```

**Important** : `[skip ci]` empêche le workflow de se relancer à l'infini.

---

## 6. Cas d'Usage Courants (Examen)

### Comment créer un workflow qui build et push une image Docker ?

```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Extract Version
        id: meta
        run: |
          echo "VERSION=$(echo ${GITHUB_SHA} | cut -c1-7)" >> $GITHUB_OUTPUT
      
      - name: Build and Push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/myapp:latest
            ${{ secrets.DOCKER_USERNAME }}/myapp:${{ steps.meta.outputs.VERSION }}
          cache-from: type=registry,ref=${{ secrets.DOCKER_USERNAME }}/myapp:buildcache
          cache-to: type=registry,ref=${{ secrets.DOCKER_USERNAME }}/myapp:buildcache,mode=max
```

### Comment ajouter des tests automatiques ?

```yaml
name: Test and Build

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: 3.9
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov
      
      - name: Run tests
        run: pytest --cov=app tests/
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost/test_db
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
```

---

# CONCEPTS TRANSVERSAUX

## 1. Isolement et Sécurité

### Namespace (Kubernetes)

Divise un cluster en compartiments logiques isolés.

```bash
kubectl get pods -n production  # Voir les pods du namespace production
kubectl apply -f deployment.yaml -n staging  # Déployer dans staging
```

### VPC (AWS)

Réseau privé isolé sur AWS.

```hcl
resource "aws_vpc" "prod" {
  cidr_block = "10.0.0.0/16"  # Aucune collision possible avec d'autres VPCs
}
```

### Docker Networks

Isolent les conteneurs en groupes.

```bash
docker network create app-network
docker run --network app-network nginx
```

---

## 2. Variables d'Environnement

### Docker

```dockerfile
ENV LOG_LEVEL=INFO
ENV DB_HOST=localhost
```

```bash
docker run -e LOG_LEVEL=DEBUG myapp
```

### Kubernetes

```yaml
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: LOG_LEVEL
      value: "DEBUG"
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
```

### Terraform

```hcl
variable "log_level" {
  default = "INFO"
}

resource "aws_instance" "app" {
  user_data = base64encode(<<-EOF
             #!/bin/bash
             export LOG_LEVEL=${var.log_level}
             EOF
  )
}
```

---

## 3. Health Checks

### Docker

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1
```

### Kubernetes

```yaml
spec:
  containers:
  - name: app
    livenessProbe:
      httpGet:
        path: /health
        port: 8000
      initialDelaySeconds: 10
      periodSeconds: 5
```

---

## 4. Scaling

### Docker Compose

```yaml
services:
  web:
    image: nginx
    deploy:
      replicas: 3
```

### Kubernetes

```bash
kubectl scale deployment myapp --replicas=10
```

### Terraform + AWS

```hcl
resource "aws_autoscaling_group" "app" {
  min_size         = 2
  max_size         = 10
  desired_capacity = 5
}
```

---

## 5. Monitoring et Logging

### Docker

```bash
docker logs container_name       # Voir les logs
docker stats container_name      # CPU/RAM en temps réel
```

### Kubernetes

```bash
kubectl logs pod-name
kubectl logs -f pod-name         # Suivi temps réel
kubectl describe pod pod-name    # Tous les détails
kubectl top pods                 # CPU/RAM
```

### Terraform

Les ressources AWS peuvent être monitorées via CloudWatch (AWS).

---

## 6. Versionning

### Docker

```bash
docker tag myapp:1.0 myapp:latest
docker push myapp:1.0
docker push myapp:latest
```

### Kubernetes

```yaml
spec:
  template:
    spec:
      containers:
      - image: myapp:v1.2.3  # Toujours spécifier une version exacte !
```

### Terraform

Le fichier `.terraform.lock.hcl` fixe les versions des providers.

### GitHub

Les tags Git permettent de versionner les releases.

---

## 7. Réseautage

### Docker Compose

```yaml
services:
  web:
    image: nginx
    networks:
      - app-network
  db:
    image: postgres
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

# web peut appeler http://db:5432
```

### Kubernetes

```yaml
spec:
  containers:
  - name: app
    env:
    - name: DB_HOST
      value: "postgres-service"  # DNS automatique
```

### AWS (Terraform)

```hcl
resource "aws_security_group" "app" {
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.db.id]
  }
}
```

---

## 8. Dépannage Rapide

| Technologie | Problème | Solution |
|-------------|----------|----------|
| **Docker** | Image ne build pas | `docker build --no-cache` |
| **Docker** | Conteneur plante immédiatement | `docker logs <nom>`, vérifier CMD |
| **Kubernetes** | Pod en pending | `kubectl describe pod <nom>` → pas assez de ressources ? |
| **Kubernetes** | App inaccessible | Vérifier Service + Ingress, `kubectl get svc` |
| **Terraform** | Erreur de syntaxe | `terraform validate` |
| **Terraform** | État désynchronisé | `terraform refresh` |
| **GitHub Actions** | Workflow ne se déclenche pas | Vérifier le `on:` trigger |
| **GitHub Actions** | Secrets non accessibles | Vérifier le nom exact du secret |

---

## CONCLUSION

Cette guide couvre les **principes fondamentaux** de chaque technologie. Pour l'examen :

1. **Maîtrisez les commandes de base** (kubectl, docker, terraform)
2. **Comprenez les objets/ressources** (Pod, Deployment, Service, Instance EC2, etc.)
3. **Pratiquez les workflows courants** (déployer une app, scaler, mettre à jour)
4. **Sachez déboguer** (logs, describe, plan, etc.)
5. **Connaissez les patterns** (variables d'environnement, probes, security groups)

Vous êtes maintenant prêt à répondre à n'importe quelle question d'examen !

