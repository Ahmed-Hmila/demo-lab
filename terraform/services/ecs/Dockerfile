# terraform/services/ecs/Dockerfile

# Utiliser une image de base légère
FROM nginx:alpine

# Supprimer le fichier index.html par défaut
RUN rm /usr/share/nginx/html/index.html

# Créer un fichier index.html avec le message spécifié
RUN echo "<h1>hello forme ecs</h1>" > /usr/share/nginx/html/index.html

# Le port 80 est exposé par défaut par Nginx
EXPOSE 80

# Démarrer Nginx
CMD ["nginx", "-g", "daemon off;"]
