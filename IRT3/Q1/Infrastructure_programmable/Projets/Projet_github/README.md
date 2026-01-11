# CI-CD-Actions-DockerHUB-Argo

**CI/CD d'une application flask en utilisant Github Actions pour push des images Docker et les déployer avec Kubernetes et Argo CD**  
![Pipeline](img/workflow.png)

## Contexte - Pipeline GitOps intégrant DevOps

### Étape 1

* Application Flask simple dans [app/app.py](app/app.py)
* Dockerfile qui permet de déployer l'application flask dans [app/Dockerfile](app/Dockerfile)
* Workflow GitHub Actions dans [.github/workflows/dockerBuildPush.yml](.github/workflows/dockerBuildPush.yml)
  * Créer des variables d'environnement secrètes (DOCKERHUB_TOKEN et DOCKERHUB_USERNAME) dans `Settings -> Secrets and variables -> Actions -> New repository secret` (Générer d'abord votre token dans les paramètres Docker Hub)
  * Modifier la variable d'environnement IMAGE_NAME en mettant le nom de votre image (modifier uniquement "ci-cd-actions-dockerhub-argo")
* Vérifier que la pipeline s'exécute sans erreur
* Vérifier que l'image a bien été envoyée dans le repository Docker Hub

### Étape 2

* Créer les fichiers K8s ([k8s/deployment.yml](k8s/deployment.yml) et [k8s/service.yml](k8s/service.yml))
* Installer et lancer Argo cd

    ```bash
    # Installer le Load Balancer
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0-beta.0/deploy/static/provider/cloud/deploy.yaml

    # Install Argo CD
    kubectl create namespace argocd 
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    # Mapper les ports pour accéder à Argo cd
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```

* Se log dans Argo cd

    ```bash
    # Génerer son mot de passe
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}'

    # Décoder le base 64 reçu
    # Se log avec les credentials admin:base64Décodé
    ```

* Déployer l'application dans Argo cd

    ```bash
    # Renseigner les champs
    PROJECT: default
    CLUSTER: https://kubernetes.default.svc
    NAMESPACE: default
    REPO URL: https://github.com/caimath/CI-CD-Actions-DockerHUB-Argo.git # Remplacer par l'URL de votre repo GitHub
    PATH: k8s
    ```

* Résultat attendu sur Argo cd
![img/flask-appArgocd.png](img/flask-appArgocd.png)

* Vérifier que l'application flask fonctionne et utilise bien les 3 pods: aller sur `localhost:30007` et rafraichir la page pour vérifier que le nom du pod utilisé change (Load balancing des pods)
* Sur Argo cd, SYNC POLICY peut être mis sur manual ou automatic
