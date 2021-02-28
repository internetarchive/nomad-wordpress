FROM nginx
LABEL maintainer="tracey <tracey AT archive DOT org>"

ENV DEBIAN_FRONTEND noninteractive

ENV DOCUMENT_ROOT /usr/share/nginx/html
WORKDIR           /usr/share/nginx/html

RUN apt-get update  && \
    apt-get -yqq install php-fpm unzip wget apt-utils php-curl php-gd php-intl php-pear php-imagick \
                 php-imap php-ps php-pspell php-recode php-tidy php-xmlrpc php-xsl \
                 php-memcache php-sqlite3  && \
    rm -rf *  && \
    # setup WP
    curl -s https://wordpress.org/latest.tar.gz | tar xzf - --strip-components=1 && \
    # setup sqlite
    curl -o sq.zip https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip && \
      unzip sq.zip -d wp-content/plugins/  &&  rm sq.zip && \
    cp wp-content/plugins/sqlite-integration/db.php  wp-content && \
    cp wp-config-sample.php  wp-config.php && \
    # nginx config
    sed -i -e "s/keepalive_timeout\s*65/keepalive_timeout 2/"                             /etc/nginx/nginx.conf && \
    sed -i -e "s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 10m/"   /etc/nginx/nginx.conf && \
    sed -i -e "s|include /etc/nginx/conf.d/\*.conf|include /etc/nginx/sites-enabled/\*|g" /etc/nginx/nginx.conf && \
    # php-fpm config
    sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g"                 /etc/php/*/fpm/php.ini && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 10M/g" /etc/php/*/fpm/php.ini && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 10M/g"             /etc/php/*/fpm/php.ini && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/*/fpm/pool.d/www.conf && \
    sed -i -e "s/;listen.mode = 0660/listen.mode = 0666/g"                     /etc/php/*/fpm/pool.d/www.conf  && \
    # https://wordpress.org/support/article/administration-over-ssl/#using-a-reverse-proxy
    RUN sed -i -e "s|<?php|<?php define('FORCE_SSL_ADMIN',true); \$_SERVER['HTTPS']='on';|" wp-config.php && \
    chown -R www-data.www-data .

COPY default.conf /etc/nginx/sites-available/default.conf
RUN mkdir -p /etc/nginx/sites-enabled && \
    ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf


EXPOSE 5000

CMD service php7.3-fpm start && nginx -g 'daemon off;'
