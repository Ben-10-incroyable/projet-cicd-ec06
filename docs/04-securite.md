# 04 — Fiche sécurité minimale

## Principes appliqués dans le projet
| Sujet | Pratique retenue |
|-------|------------------|
| **Aucun secret dans le code** | Aucun mot de passe / token en clair. L'authentification GHCR utilise `GITHUB_TOKEN`, injecté automatiquement par GitHub et détruit en fin de run. |
| **Permissions minimales** | Chaque workflow déclare `permissions:` au strict nécessaire (`packages: write` uniquement pour publier). |
| **Image de base maîtrisée** | Version épinglée (`nginx:1.27-alpine`) plutôt qu'un tag flottant. |
| **Surface minimale** | Base Alpine ; suppression du contenu Nginx par défaut. |
| **Identité de l'artefact** | Chaque image identifiée par un **digest sha256** immuable en plus des tags. |
| **Validation avant production** | Étape `recette` obligatoire avant promotion ; environnement `production-simulee` pouvant exiger une approbation manuelle. |
| **Healthcheck** | Un `HEALTHCHECK` intégré détecte un conteneur non fonctionnel. |
| **Traçabilité** | Historique de commits, logs de runs Actions, tags + digests GHCR. |

## Rôle du GITHUB_TOKEN
`GITHUB_TOKEN` est un jeton éphémère généré automatiquement pour chaque exécution de
workflow. Il n'est jamais stocké dans le dépôt, dispose de permissions limitées, et
expire à la fin du job. C'est le moyen recommandé pour s'authentifier à GHCR sans gérer
de secret manuel.

## Pistes d'amélioration (production)
- Scan de vulnérabilités de l'image (Trivy, Grype) intégré au CI.
- Signature des images (cosign / Sigstore) pour garantir la provenance.
- Mises à jour automatiques des dépendances (Dependabot).
- Secrets applicatifs dans **GitHub Secrets** ou un coffre (Vault).
