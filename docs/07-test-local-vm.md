# 07 — Test local & VM personnelle

## Test local avec Docker / Docker Compose
J'ai testé l'image et l'orchestration localement avant tout push, sur mon poste Windows
avec Docker Desktop :
```powershell
docker build -t catal-log .
docker run -d -p 8080:80 catal-log        # -> http://localhost:8080 : 200 OK
docker compose up -d --scale web=2        # orchestration + scaling
docker compose ps                          # 2 web + 1 gateway Running
```
La répartition de charge entre les deux instances a été vérifiée via l'en-tête
`X-Served-By` (deux adresses distinctes observées). Captures dans `docs/img/`.

## VM personnelle
Je n'ai pas utilisé de VM personnelle : la chaîne CI/CD s'exécute intégralement sur des
**runners GitHub hébergés et éphémères**, ce qui correspond à l'objectif « sans serveur à
administrer ». Les tests locaux ont été réalisés directement via Docker Desktop sous
Windows, sans nécessiter de VM dédiée. Une VM n'aurait pas apporté de valeur
supplémentaire pour valider le pipeline.
