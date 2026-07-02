# 02 - Schéma de la chaîne CICD

## Schéma logique


flowchart LR
    A[Commit GitHub] --> B[01-ci.yml : build + test]
    B --> C[02-publish-ghcr.yml : publication GHCR]
    C --> D[Image taguée + digest]
    D --> E[03-promote.yml : validation recette]
    E --> F[Promotion production-simulee sans rebuild]


## Explication

- **01-ci.yml (build + test)** : déclenché à chaque commit poussé sur `main`. Il vérifie la présence des fichiers obligatoires, valide `version.json`, construit l'image Docker puis lance le conteneur et teste qu'il répond en HTTP 200 avec le bon contenu.
- **02-publish-ghcr.yml (publication GHCR)** : se connecte à GHCR avec le `GITHUB_TOKEN`, construit l'image et la pousse avec plusieurs tags (`latest`, `recette`, `sha-<commit>`), puis affiche le digest.
- **Image taguée + digest** : l'image publiée est identifiée par ses tags (noms lisibles) et par son digest sha256 (empreinte unique et immuable).
- **03-promote.yml (validation recette)** : premier job, tire l'image `recette` publiée, la relance et la reteste en HTTP dans l'environnement GitHub `recette`.
- **Promotion production-simulee sans rebuild** : second job, re-tague l'image validée en `production` sans la reconstruire (même digest), après approbation manuelle sur l'environnement `production-simulee`.

## Orchestration légère

Le fichier compose.yml décrit un service web et un second service de test. Il sert à documenter et simuler une coordination de conteneurs, sans prétendre remplacer une orchestration de production.

Dans ce projet :
- le service **web** est le site Nginx (l'artefact publié) ;
- le second service, **gateway**, est un reverse proxy Nginx qui expose le point d'entrée (port 8080) et répartit les requêtes vers les instances de web.

La commande `docker compose up --scale web=2` lance deux instances de web ; le reverse proxy les découvre via le DNS interne de Docker et répartit les requêtes (round-robin), ce qui simule une mise à l'échelle.

## Limite importante

Docker Compose est utile pour une mise en situation, un test local ou une démonstration de coordination. En production réelle, il faudrait traiter d'autres sujets : haute disponibilité, répartition de charge, supervision, politique de déploiement, rollback, sécurité, sauvegarde et restauration.
