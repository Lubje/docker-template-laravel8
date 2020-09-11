ARG NGINX_VERSION

FROM nginx:${NGINX_VERSION}

COPY /docker/nginx/conf.d/default.conf /etc/nginx/conf.d/
COPY /docker/nginx/h5bp/ /etc/nginx/h5bp/
COPY /docker/nginx/mime.types /etc/nginx/
COPY /docker/nginx/nginx.conf /etc/nginx/

COPY --chown=www-data:www-data /src/public/ /var/www/html/public/
