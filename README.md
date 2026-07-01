# Projet CI/CD — EC06 (Catal-Log)

Chaîne CI/CD complète : build, test, publication et promotion d'une image Docker Nginx
contenant un site statique, via **GitHub Actions** et **GitHub Container Registry (GHCR)**.

## Arborescence

```
.
├── site/
│   ├── index.html          # Site statique personnalisé
│   └── version.json        # Métadonnées de version
├── Dockerfile              # Image Nginx reproductible
├── compose.yml             # Orchestration légère (web + gateway)
├── gateway.conf            # Reverse proxy pour la démo de scaling
├── .github/workflows/
│   ├── 01-ci.yml           # Build + test automatisé
│   ├── 02-publish-ghcr.yml # Publication GHCR (tag + digest)
│   └── 03-promote.yml      # Promotion manuelle recette -> production
└── docs/                   # Documentation, sécurité, preuves, compte rendu
```

## Le pipeline en 4 temps
1. **CI** — à chaque push : contrôle des fichiers, build Docker, test HTTP.
2. **Publish** — publication sur GHCR avec tags (`latest`, `sha-...`, `recette`) et digest.
3. **Validation recette** — l'image est retestée en environnement `recette`.
4. **Promotion** — manuelle (`workflow_dispatch`) : le **même artefact** (même digest)
   est re-taggé `production`, **sans rebuild**.

## Démarrage rapide (local)
```bash
docker build -t catal-log .
docker run -d -p 8080:80 catal-log        # http://localhost:8080
docker compose up -d --scale web=2        # orchestration + scaling
```
