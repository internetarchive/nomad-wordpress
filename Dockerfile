FROM wordpress


ENV WORDPRESS_DB_USER=demo-user
ENV WORDPRESS_DB_NAME=demo-db

# We're going to serve wordpress on http:// from our container (to caddy/haproxy/LB)
# but we need the site itself to issue https:// links on its own pages to the browser
# RUN sed -i -e "s|<?php|<?php define('FORCE_SSL_ADMIN',true); \$_SERVER['HTTPS']='on';|" \
#      /opt/bitnami/wordpress/wp-config.php

COPY .bashrc /

CMD \
  export WORDPRESS_DB_HOST=$NOMAD_ADDR_db && \
  #
  # Need to ensure HOSTNAME:PORT value is accurate
  # ( perl -i -pe "s/'DB_HOST'.*/'DB_HOST', '${NOMAD_ADDR_db?}');/" /bitnami/wordpress/wp-config.php || echo bootstrapping ) && \
  #
  /usr/local/bin/docker-entrypoint.sh apache2-foreground
