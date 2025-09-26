# Image de base : Python 3.10 sur Debian Bookworm (plus stable et complet que slim)
FROM python:3.10-bookworm

# Répertoire de travail dans le conteneur
WORKDIR /app

# Copier et installer les dépendances (Flask via requirements.txt)
COPY requirement.txt requirement.txt
RUN pip install --no-cache-dir -r requirement.txt

# Copier le fichier app.py dans le conteneur
COPY app.py app.py

# Exposer le port
EXPOSE 5000

# Commande de lancement
CMD ["python", "app.py"]