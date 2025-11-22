FROM wordpress

ENV WORDPRESS_DB_USER=demo-user
ENV WORDPRESS_DB_NAME=demo-db

CMD export WORDPRESS_DB_HOST=$NOMAD_ADDR_db && \
  /usr/local/bin/docker-entrypoint.sh apache2-foreground
