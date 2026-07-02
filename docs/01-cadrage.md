# 01 — Cadrage du projet

## Contexte
Catal-Log souhaite industrialiser la publication d'un petit site web statique afin
d'éviter les opérations manuelles répétitives, fiabiliser les livraisons et conserver
des preuves d'exécution.

## Objectif
Mettre en place une chaîne CI/CD simple, lisible et traçable qui construit, teste,
publie et promeut une image Docker Nginx contenant un site statique.

## Périmètre
| Inclus | Exclu |
|--------|-------|
| Build & test automatisés (GitHub Actions) | Kubernetes / orchestration de production réelle |
| Publication sur GHCR (tag + digest) | Infrastructure serveur à administrer |
| Promotion manuelle d'artefact sans rebuild | Déploiement sur des serveurs réels |
| Orchestration légère (Docker Compose) | Haute disponibilité réelle |

## Choix techniques
- **Nginx Alpine** : image légère, standard pour servir du contenu statique.
- **GitHub Actions** : runners hébergés, aucun serveur à maintenir.
- **GHCR** : registre intégré à GitHub, authentification via `GITHUB_TOKEN`.
- **Environnements GitHub** (`recette`, `production-simulee`) : simulation de la
  séparation des environnements et point d'approbation manuelle.

## Enchaînement des workflows
```
push main -> 01-ci (build+test) -> 02-publish-ghcr (tag+digest)
                                         |
                         [déclenchement manuel]
                                         v
                   03-promote : valider recette -> promouvoir production
                               (même digest, sans rebuild)
```
