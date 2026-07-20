# ===========================
# Stage 1 : build des deps
# ===========================
FROM python:3.11-slim AS builder 

# Empêche Python de bufferiser / d’écrire des .pyc
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# dossier de travail dans le conteneur
WORKDIR /app 

# Install outils de build si besoin de compiler des libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc \
    && rm -rf /var/lib/apt/lists/*

# Copier seulement les requirements pour maximiser le cache
COPY requirements.txt .

# Installer les dépendances dans un dossier dédié
RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir --target=/deps -r requirements.txt

# Copier le code applicatif
COPY . .

# ===========================
# Stage 2 : image runtime
# ===========================
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copier les dépendances construites
COPY --from=builder /deps /usr/local/lib/python3.11/site-packages

# Copier le code de l’appli
COPY --from=builder /app /app

# Exposer le port 5000 pour l’application Flask
EXPOSE 5000

# Commande pour lancer l’application au démarrage du conteneur
CMD ["python", "app.py"]
