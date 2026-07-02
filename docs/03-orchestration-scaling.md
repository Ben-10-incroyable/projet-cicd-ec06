# 03 — Orchestration & scaling (C13)

## Docker Compose comme orchestration légère
Docker Compose décrit, dans un seul fichier déclaratif, l'ensemble des services d'une
application, leur réseau, leurs dépendances et leur cycle de vie. Il joue le rôle d'un
**orchestrateur léger** : il coordonne plusieurs conteneurs, gère leur démarrage ordonné
(`depends_on`), et fournit une résolution DNS interne entre services.

Notre `compose.yml` décrit deux services :
- **web** : le site Nginx (l'artefact publié) ;
- **gateway** : un reverse proxy Nginx qui expose le point d'entrée et répartit les
  requêtes vers les instances de `web`.

Ce second service démontre la **coordination de plusieurs conteneurs**.

## Simulation de mise à l'échelle
```bash
docker compose up -d --scale web=2
```
Cette commande lance **deux instances** du service `web`. Le reverse proxy `gateway`
les découvre automatiquement via le DNS interne de Docker et répartit les requêtes.

Preuve de répartition (PowerShell) :
```powershell
for ($i=1; $i -le 6; $i++) { (Invoke-WebRequest http://localhost:8080 -UseBasicParsing).Headers["X-Served-By"] }
```
On observe l'adresse de l'instance servante changer entre les deux instances web.

## Pourquoi ce n'est PAS une orchestration de production
- **Pas d'auto-réparation multi-nœuds** : Compose se limite à la politique `restart` locale.
- **Un seul hôte** : aucune répartition multi-serveurs, aucune tolérance à la panne d'un nœud.
- **Pas d'autoscaling** : le `--scale` est manuel et fixe.
- **Pas de rolling update natif** à l'échelle d'un cluster.
- **Load balancing rudimentaire** : simple round-robin DNS.

## Limites de Docker Compose dans ce contexte pédagogique
Compose est excellent pour le développement, les tests d'intégration et les démos, mais
ne remplace pas un orchestrateur de production (Kubernetes, Nomad, Swarm) dès qu'on a
besoin de haute disponibilité, de résilience multi-nœuds, d'autoscaling ou de
déploiements progressifs à grande échelle.

## Lien avec la robustesse de la chaîne CI/CD
- **Reproductibilité** : le Dockerfile produit toujours la même image.
- **Promotion d'un artefact identifié** : l'image testée en recette est exactement
  celle promue en production (même digest), sans reconstruction.
- **Traçabilité** : chaque image porte un tag et un digest immuable, chaque exécution
  laisse une preuve dans GitHub Actions et GHCR.
