# 01 - Cadrage du projet

## Identité

- Nom et prénom : Ben-10-incroyable
- Dépôt GitHub : https://github.com/Ben-10-incroyable/projet-cicd-ec06
- Date de démarrage : 18 juin 2026

## Objectif

Mettre en place une chaîne CI/CD permettant de construire, tester, publier et promouvoir une image Docker Nginx contenant un site web statique pour le scénario Catal-Log.

## Contraintes du projet

- Travail individuel.
- Aucune infrastructure fournie, préparée, administrée ou maintenue par le formateur.
- Pas de serveur distant, pas de SSH, pas de cloud provider imposé.
- Docker local ou Docker Compose sont utilisés si l'environnement personnel le permet ; sinon la limitation doit être justifiée.
- Une VM personnelle peut être utilisée si disponible ; sinon la non-utilisation doit être justifiée.

## Choix personnels

- Dépôt : **public**, afin que les images publiées sur GHCR soient accessibles et que les preuves (runs Actions, package GHCR) soient consultables directement via un lien.
- Nommage du dépôt et de l'image : `projet-cicd-ec06` (image `ghcr.io/ben-10-incroyable/projet-cicd-ec06`, en minuscules comme l'exige GHCR).
- Stratégie de tags : `latest` (dernière version), `recette` (image candidate à valider), `sha-<commit>` (traçabilité vers le commit exact), puis `production` après promotion.
- Environnement local : utilisé. Tests réalisés sur poste Windows avec Docker Desktop (build, run, compose, scaling) avant chaque push.
- VM personnelle : non utilisée. La chaîne s'exécute sur des runners GitHub hébergés et éphémères ; Docker Desktop suffit pour les tests locaux, une VM n'apportait pas de valeur supplémentaire.
