# 08 — Compte rendu final

> Ce document doit refléter VOTRE compréhension. Complétez chaque section avec vos
> propres mots — c'est un critère d'évaluation explicite. Le texte ci-dessous est une
> base de départ à personnaliser.

## Ce que j'ai réalisé
J'ai mis en place une chaîne CI/CD qui construit, teste, publie et promeut une image
Docker Nginx contenant un site statique, via GitHub Actions et GHCR. La chaîne comprend
trois workflows : intégration continue (build + test), publication sur GHCR, et promotion
manuelle de la recette vers une production simulée sans reconstruction.

## Comment fonctionne ma chaîne
- **01-ci** : déclenché à chaque push, il vérifie les fichiers obligatoires, valide le
  JSON, construit l'image, lance le conteneur et teste la réponse HTTP 200.
- **02-publish-ghcr** : se connecte à GHCR via le GITHUB_TOKEN, construit et pousse
  l'image avec les tags latest / sha / recette, et affiche le digest.
- **03-promote** : validé manuellement, il reteste l'image de recette puis la re-tag en
  production sans rebuild (même digest).

## Le point clé : promotion sans rebuild
Promouvoir le même artefact (même digest) plutôt que reconstruire garantit qu'on déploie
exactement ce qui a été testé. Cela assure la reproductibilité et rend le rollback simple.

## Difficultés rencontrées et solutions
- (à compléter avec votre vécu, ex : Dockerfile enregistré en .txt, gateway.conf créé
  comme dossier au lieu d'un fichier, permissions packages: write à activer, etc.)

## Ce que j'ai compris sur le CI/CD
Reproductibilité, traçabilité par tag/digest, séparation des environnements, sécurité des
secrets, et limites de Docker Compose face à une orchestration réelle.

## Limites de mon approche
Mono-hôte, pas d'autoscaling ni d'auto-réparation multi-nœuds, production simulée, pas de
scan de vulnérabilités ni de signature d'image (voir docs/05).

## Ce que j'ajouterais pour une vraie production
Secrets dans un coffre, monitoring, haute disponibilité, scan de vulnérabilités, rollback
outillé (voir docs/05-analyse-production.md).
