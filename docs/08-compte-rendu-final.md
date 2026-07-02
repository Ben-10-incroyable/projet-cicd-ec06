# 08 - Compte rendu final


## 1. Synthèse

J'ai mis en place une chaîne CI/CD complète qui construit, teste, publie et promeut une image Docker Nginx contenant un site statique « Catal-Log », via GitHub, GitHub Actions et GitHub Container Registry (GHCR). Le build, le test et la publication sont automatiques ; la mise en production simulée passe par une validation humaine explicite.

## 2. Fonctionnement technique

Le chemin complet est le suivant :

1. **Commit** : je pousse une modification sur la branche `main`.
2. **Build + test (01-ci.yml)** : GitHub Actions vérifie les fichiers, valide version.json, construit l'image et teste que le conteneur répond en HTTP 200 avec le bon contenu.
3. **Publication GHCR (02-publish-ghcr.yml)** : l'image est poussée sur GHCR avec les tags latest, recette, sha-<commit>, et son digest est affiché.
4. **Validation recette (03-promote.yml, job 1)** : l'image recette est retirée du registre, relancée et retestée dans l'environnement `recette`.
5. **Promotion production-simulee (03-promote.yml, job 2)** : après approbation manuelle, l'image validée est re-taggée en `production` sans reconstruction (même digest).

## 3. Conteneurisation

Le Dockerfile part d'une image officielle `nginx:1.27-alpine` (légère, version épinglée pour la reproductibilité). Il supprime la page par défaut, copie le contenu de `site/` dans le répertoire servi par Nginx, expose le port 80 et intègre un HEALTHCHECK. L'image produite sert le site statique ; elle est exécutée en conteneur et testée automatiquement (HTTP 200). Les preuves sont les runs 01-CI et la publication sur GHCR.

## 4. Orchestration et scaling

Le fichier compose.yml décrit deux services : `web` (le site Nginx) et `gateway` (un reverse proxy qui répartit les requêtes). La commande `docker compose up --scale web=2` lance deux instances de web ; la répartition est vérifiée via l'en-tête X-Served-By (deux adresses alternent). Limites : un seul hôte, pas de haute disponibilité réelle, pas d'autoscaling ni d'auto-réparation multi-nœuds. Docker Compose est un orchestrateur léger, pas un remplacement de Kubernetes.

## 5. Automatisation et sécurité

Trois workflows automatisent la chaîne. La publication et la promotion utilisent GHCR. L'authentification se fait avec le GITHUB_TOKEN (jeton temporaire, permissions limitées, détruit en fin de run), sans aucun secret écrit dans le code. Les permissions des workflows sont limitées au strict nécessaire (contents: read, packages: write uniquement quand il faut publier). Le rollback s'appuie sur les digests immuables ; la sauvegarde couvre le dépôt, les workflows, la documentation, les images et les preuves.

## 6. Production réelle

**Gestion des secrets** : ne jamais stocker de secret dans le code (l'historique Git les conserverait). En production, placer les identifiants de registre, clés d'accès serveur/cluster, variables sensibles et clés de signature dans GitHub Secrets ou un coffre (Vault).

**Rollback** : re-cibler un digest antérieur connu et le redéployer, sans rebuild — même principe que la promotion.

**Sauvegarde / restauration** : sauvegarder dépôt, workflows, documentation, images (digests), configuration, preuves et secrets (séparément) ; restaurer en reclonant et en redéployant un artefact connu par son digest.

**Deux éléments complémentaires** : (1) validation manuelle avant production avec séparation des responsabilités (Prevent self-review) ; (2) contrôle des vulnérabilités par scan d'image bloquant en CI.

## 7. Preuves

- Dépôt : https://github.com/Ben-10-incroyable/projet-cicd-ec06
- Runs GitHub Actions (01-CI, 02-Publish, 03-Promote) : onglet Actions du dépôt, tous en succès.
- Image GHCR : https://github.com/Ben-10-incroyable/projet-cicd-ec06/pkgs/container/projet-cicd-ec06
- Tags : latest, recette, production, sha-<commit>.
- Digest : sha256:9c37039c69da51da068ce87313d5bd68dd35fe190bf1066b7c55d3e32942e56e
- Captures : dossier docs/img/ (Actions, publication, promotion sans rebuild, package GHCR, approbation, scaling, site local).

## 8. Difficultés et apprentissages

Difficultés rencontrées et résolues :

- **Dockerfile enregistré en Dockerfile.txt** sous Windows : build impossible tant que le fichier n'était pas renommé en Dockerfile.
- **gateway.conf créé comme un dossier** au lieu d'un fichier : Docker refusait de le monter ; recréé correctement en fichier via PowerShell.
- **Fichier nommé Compose.yaml** : renommé en compose.yml pour respecter le livrable demandé.
- **Erreur « repository name must be lowercase »** dans la promotion : mon pseudo contient des majuscules, or GHCR exige des minuscules ; j'ai ajouté une étape convertissant le nom du dépôt en minuscules.

Apprentissages : j'ai compris la différence entre un tag (étiquette mobile) et un digest (empreinte immuable), l'intérêt de promouvoir un artefact déjà testé plutôt que de le reconstruire (reproductibilité, rollback simple), le rôle du GITHUB_TOKEN et des permissions minimales, et les limites d'une orchestration légère face à une production réelle.
