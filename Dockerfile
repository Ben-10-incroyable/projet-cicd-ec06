# Image de base officielle et legere : Nginx sur Alpine
FROM nginx:1.27-alpine

# Metadonnees de l'image 
LABEL org.opencontainers.image.title="catal-log-static-site" \
      org.opencontainers.image.description="Site statique Catal-Log servi par Nginx"

# Suppression de la page par defaut de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copie du site statique dans le repertoire servi par Nginx
COPY site/ /usr/share/nginx/html/

# Nginx ecoute sur le port 80
EXPOSE 80

# Verification de sante integree a l'image
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1
