# 06 — Preuves

> À compléter avec vos liens et captures réels après exécution.

## Dépôt et exécutions
- [ ] Lien du dépôt GitHub : `https://github.com/Ben-10-incroyable/projet-cicd-ec06`
- [ ] Run CI réussi (01-ci) : _lien_ + capture
- [ ] Run Publish réussi (02-publish) : _lien_ + capture
- [ ] Run Promote réussi (03-promote) : _lien_ + capture

## Build & test
- [ ] Preuve du build Docker automatisé : capture de l'étape "Build de l'image".
- [ ] Preuve du test HTTP automatisé : capture de l'étape "Test HTTP" (Code HTTP : 200).

## GHCR
- [ ] Image visible dans GHCR : capture de la page Packages.
- [ ] **Tag** utilisé : `_______`
- [ ] **Digest** de l'image : `sha256:__________________________________`

## Recette & promotion
- [ ] Preuve de validation recette : capture du job `valider-recette` en succès.
- [ ] Preuve de promotion `production-simulee` **sans rebuild** : capture du job
      `promouvoir-production` + résumé montrant le même digest en source et cible.

## Orchestration
- [ ] Extrait / lien du `compose.yml`.
- [ ] Preuve de la simulation de scaling : sortie de la boucle `X-Served-By` montrant
      deux instances, + `docker compose ps` avec 2 web + 1 gateway.

## Environnement local / VM
- [ ] Preuve du test local Docker/Compose (capture) **ou** justification.
- [ ] Utilisation d'une VM personnelle (capture) **ou** justification de non-utilisation.

## Comment obtenir le digest
Sur la page du package GHCR, ou en CLI :
```bash
docker pull ghcr.io/ben-10-incroyable/projet-cicd-ec06:recette
docker inspect --format='{{index .RepoDigests 0}}' ghcr.io/ben-10-incroyable/projet-cicd-ec06:recette
```
