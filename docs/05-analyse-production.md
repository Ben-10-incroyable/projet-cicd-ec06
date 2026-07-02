# 05 — Analyse : passage vers une production réelle

Le projet simule la production. Voici ce qu'il faudrait ajouter pour en faire une vraie
production. Les **trois points obligatoires** sont traités, suivis de compléments.

## 1. Gestion des secrets
**Pourquoi aucun secret dans le code** : un dépôt Git conserve tout l'historique. Un
secret commité reste visible dans l'historique même après suppression. Un secret ne doit
donc jamais être écrit en clair dans les fichiers versionnés.

**Usage du GITHUB_TOKEN** : pour publier sur GHCR, on n'utilise aucun secret manuel. On
s'authentifie avec `${{ secrets.GITHUB_TOKEN }}`, un jeton temporaire fourni
automatiquement par GitHub, à permissions limitées et détruit en fin de run.

**En production réelle**, devraient être placés dans **GitHub Secrets** ou un **coffre de
secrets** (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault) :
- identifiants d'un registre privé externe,
- clés d'accès au serveur ou au cluster (SSH, kubeconfig),
- variables sensibles de l'application (clés API, mots de passe BDD),
- clés de signature d'image.

## 2. Rollback
La chaîne rend le rollback simple parce que chaque livraison est un artefact identifié et
immuable :
- chaque image publiée porte un **tag** et surtout un **digest** `sha256` immuable ;
- pour revenir en arrière, on ne reconstruit rien : on re-promeut un artefact déjà
  construit et testé, exactement comme le fait `03-promote.yml` ;
- concrètement : re-tagger `production` vers le digest de la version précédente, puis
  redéployer ce tag.

```bash
docker pull ghcr.io/user/repo@sha256:<digest_precedent>
docker tag  ghcr.io/user/repo@sha256:<digest_precedent> ghcr.io/user/repo:production
docker push ghcr.io/user/repo:production
```
Le binaire étant identique à celui qui tournait avant, le rollback est fiable et
prévisible. C'est l'intérêt de promouvoir un artefact plutôt que de reconstruire.

## 3. Sauvegarde / restauration
À sauvegarder pour pouvoir tout reconstruire :
- **Dépôt GitHub** : code source, historique, tags Git.
- **Workflows** (`.github/workflows/`) : la définition de la chaîne elle-même.
- **Documentation** (`docs/`) : cadrage, sécurité, preuves.
- **Images publiées sur GHCR** : au moins les digests des versions en service.
- **Configuration** : `compose.yml`, `Dockerfile`, `gateway.conf`, variables d'env.
- **Preuves** : logs des runs, captures, correspondances tag <-> digest.
- **Secrets** : sauvegardés séparément et de façon sécurisée (dans le coffre, pas dans Git).

La restauration consiste à recloner le dépôt, restaurer les secrets dans le coffre, et
redéployer un artefact connu par son digest — sans dépendre d'un rebuild.

## Éléments complémentaires (au moins deux exigés)
- **Supervision / monitoring** : métriques (Prometheus), alertes sur disponibilité et
  erreurs HTTP, pour détecter un incident avant l'utilisateur.
- **Journalisation centralisée** : agrégation des logs (Loki, ELK) pour l'audit et le
  diagnostic post-incident.
- **Haute disponibilité** : plusieurs répliques sur plusieurs nœuds derrière un load
  balancer, pour tolérer la panne d'une instance.
- **Contrôle des vulnérabilités** : scan d'images (Trivy) bloquant en CI.
- **Séparation stricte des environnements** : recette et production isolées, avec
  validation manuelle avant production.
