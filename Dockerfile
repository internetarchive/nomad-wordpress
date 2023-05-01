FROM bitnami/wordpress-nginx

ENV WORDPRESS_DATABASE_USER wp_user

# We're going to serve wordpress on http:// from our container (to caddy/haproxy/LB)
# but we need the site itself to issue https:// links on its own pages to the browser
RUN sed -i -e "s|<?php|<?php define('FORCE_SSL_ADMIN',true); \$_SERVER['HTTPS']='on';|" \
      /opt/bitnami/wordpress/wp-config.php

COPY .bashrc /

CMD \
  export WORDPRESS_DATABASE_PASSWORD=${MARIADB_PASSWORD?} && \
  export WORDPRESS_DATABASE_HOST=$(       echo "${NOMAD_ADDR_db?}" | cut -f1 -d:) && \
  export WORDPRESS_DATABASE_PORT_NUMBER=$(echo "${NOMAD_ADDR_db?}" | cut -f2 -d:) && \
  #
  # Need to ensure HOSTNAME:PORT value is accurate
  perl -i -pe "s/'DB_HOST'.*/'DB_HOST', '${NOMAD_ADDR_db?}');/" /bitnami/wordpress/wp-config.php && \
  fgrep DB_HOST /bitnami/wordpress/wp-config.php && \
  #
  /opt/bitnami/scripts/wordpress/entrypoint.sh  /opt/bitnami/scripts/nginx-php-fpm/run.sh
