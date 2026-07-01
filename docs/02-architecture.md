# 02 — Architecture

## Schéma global
```
Développeur --git push--> GitHub (dépôt : site/, Dockerfile, compose.yml, workflows)
                                   |
                                   v  déclenche
                          GitHub Actions (runners hébergés, éphémères)
                             01-ci      : build image -> test HTTP
                             02-publish : push GHCR (tag + digest)
                                   |
                                   v  docker push
                          GHCR : ghcr.io/user/repo
                                 :latest :sha-... :recette  (digest sha256:...)
                                   |
                  03-promote (manuel, workflow_dispatch)
                                   |
        +--------------------------+---------------------------+
        v                                                      v
   env: recette                              env: production-simulee
   pull + retest        --re-tag du digest-->   tag :production
                        (aucun rebuild)
```

## Orchestration locale (compose.yml)
```
                     :8080
                       |
                  [ gateway ]  (reverse proxy Nginx)
                       |  répartit (round-robin DNS interne Docker)
             +---------+---------+
             v                   v
        [ web #1 ]          [ web #2 ]   docker compose up --scale web=2
         Nginx                Nginx
```

## Réseau et flux
- Un seul réseau bridge `app-net` isole les services.
- Seul `gateway` expose un port sur l'hôte (`8080`) ; `web` reste interne (`expose`).
- La résolution DNS interne de Docker permet à `gateway` de joindre toutes les
  instances de `web` lorsqu'on scale.
