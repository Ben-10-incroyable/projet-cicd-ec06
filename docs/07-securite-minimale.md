# 07 - Sécurité minimale

## Permissions GitHub Actions

Chaque workflow déclare des permissions limitées au strict nécessaire, selon le principe du moindre privilège :

- 01-ci.yml : `contents: read` (lecture du code uniquement, aucun besoin d'écriture).
- 02-publish-ghcr.yml : `contents: read`, `packages: write` (écriture requise pour publier l'image sur GHCR).
- 03-promote.yml : `contents: read`, `packages: write` (écriture requise pour re-tagger et pousser l'image en production).

Limiter les permissions réduit la surface d'attaque : si un workflow était compromis, il ne pourrait pas faire plus que ce qui lui est explicitement accordé.

## Gestion des secrets

**Pourquoi aucun secret ne doit être stocké dans le code** : un dépôt Git conserve tout l'historique. Un secret écrit en clair reste visible dans l'historique même après suppression, et est exposé à toute personne ayant accès au dépôt (ou en cas de fuite).

**Usage du GITHUB_TOKEN dans ce projet** : la connexion à GHCR se fait avec `${{ secrets.GITHUB_TOKEN }}`, un jeton temporaire généré automatiquement par GitHub pour chaque exécution de workflow. Il a des permissions limitées à ce qu'on lui accorde et il est détruit à la fin du job. Aucun mot de passe n'est donc écrit dans le code.

**Éléments à placer dans GitHub Secrets ou un coffre en production réelle** : identifiants d'un registre privé externe, clés d'accès au serveur ou au cluster (SSH, kubeconfig), variables sensibles de l'application (clés API, mots de passe de base de données), clés de signature d'image.

## Rollback

Chaque livraison est un artefact identifié par un tag et un digest immuable. Pour revenir à une version précédente, on ne reconstruit rien : on re-tague `production` vers le digest de la version antérieure connue et fonctionnelle, puis on redéploie ce tag.

```bash
docker pull ghcr.io/ben-10-incroyable/projet-cicd-ec06@sha256:<digest_precedent>
docker tag  ghcr.io/ben-10-incroyable/projet-cicd-ec06@sha256:<digest_precedent> ghcr.io/ben-10-incroyable/projet-cicd-ec06:production
docker push ghcr.io/ben-10-incroyable/projet-cicd-ec06:production
```

Le binaire étant identique à celui qui tournait avant, le rollback est fiable et prévisible. C'est le même mécanisme que la promotion (promouvoir un artefact déjà construit).

## Sauvegarde / restauration

À sauvegarder :

- le dépôt GitHub (code source, historique des commits, tags Git) ;
- les workflows (.github/workflows/), qui définissent la chaîne elle-même ;
- la documentation (docs/) ;
- les images publiées sur GHCR (au moins les digests des versions en service) ;
- la configuration (Dockerfile, compose.yml, gateway.conf, variables d'environnement) ;
- les preuves (logs de runs, captures, correspondances tag <-> digest) ;
- les secrets, sauvegardés séparément et de façon sécurisée (dans un coffre, jamais dans Git).

Restauration : recloner le dépôt, restaurer les secrets dans le coffre, puis redéployer un artefact connu par son digest, sans dépendre d'une reconstruction.

## Deux éléments complémentaires

**1. Validation manuelle avant production** : l'environnement `production-simulee` exige une approbation (Required reviewer) avant tout déploiement. En production réelle, on activerait aussi « Prevent self-review » pour qu'une personne différente de l'auteur du déploiement doive l'approuver (séparation des responsabilités).

**2. Contrôle des vulnérabilités** : on ajouterait un scan d'image (par exemple Trivy) dans le workflow CI, bloquant la publication si des vulnérabilités critiques sont détectées, afin de ne jamais promouvoir une image dangereuse.
