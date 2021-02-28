FROM php:fpm-alpine
LABEL maintainer="tracey <tracey AT archive DOT org>"

ENV DEBIAN_FRONTEND noninteractive

ENV DOCUMENT_ROOT /usr/share/nginx/html
WORKDIR           /usr/share/nginx/html

# https://wordpress.org/plugins/memcached/#installation   xxx
#   https://scotty-t.com/2012/01/20/wordpress-memcached/  xxx

RUN apk add bash git nginx imagemagick-dev unzip wget php-curl php-gd php-intl php-pear \
        php-imap php-pspell php-tidy php-xmlrpc php-xsl php-sqlite3 && \
        # php-ps -- unavail but pretty sure dont need xxx
    # igbinary for php-memcache
    apk add php8-pecl-igbinary && \
    echo extension=/usr/lib/php8/modules/igbinary.so >| /usr/local/etc/php/conf.d/igbinary.ini && \
    echo igbinary.compact_strings=On                 >> /usr/local/etc/php/conf.d/igbinary.ini && \
    echo session.serialize_handler=igbinary          >> /usr/local/etc/php/conf.d/igbinary.ini && \
    # logically php-memcache
    apk add git autoconf gcc g++ make zlib-dev libmemcached libmemcached-dev php-opcache && \
    git clone https://github.com/php-memcached-dev/php-memcached /tmp/php-memcached && \
    # xxx get configure below to see igbinary
    cd /tmp/php-memcached && phpize && ./configure && make -j4 && make install && \
    MEMD=/usr/local/lib/php/extensions/no-debug-non-zts-20200930 && \
    echo "extension=$MEMD/memcached.so" >| /usr/local/etc/php/conf.d/memcached.ini && \
    # logically php-imagick
    git clone https://github.com/Imagick/imagick.git /usr/src/php/ext/imagick && \
      docker-php-ext-install  imagick && \
    # start docroot clean
    rm -rf *  && \
    # setup WP
    curl -s https://wordpress.org/latest.tar.gz | tar xzf - --strip-components=1 && \
    # setup sqlite
    curl -o sq.zip https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip && \
      unzip sq.zip -d wp-content/plugins/  &&  rm sq.zip && \
    cp wp-content/plugins/sqlite-integration/db.php  wp-content && \
    # start with stock config
    cp wp-config-sample.php  wp-config.php && \
    # https://wordpress.org/support/article/administration-over-ssl/#using-a-reverse-proxy
    sed -i -e "s|<?php|<?php define('FORCE_SSL_ADMIN',true); \$_SERVER['HTTPS']='on';|" wp-config.php && \
    # nginx config
    sed -i -e "s/keepalive_timeout\s*65/keepalive_timeout 2/"                             /etc/nginx/nginx.conf && \
    sed -i -e "s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 10m/"   /etc/nginx/nginx.conf && \
    sed -i -e "s|include /etc/nginx/conf.d/\*.conf|include /etc/nginx/sites-enabled/\*|g" /etc/nginx/nginx.conf && \
    # php-fpm config
    sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g"                 /etc/php/*/fpm/php.ini && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 10M/g" /etc/php/*/fpm/php.ini && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 10M/g"             /etc/php/*/fpm/php.ini && \
    echo 'catch_workers_output = yes' >> /etc/php/*/fpm/pool.d/www.conf && \
    echo 'listen.mode = 0666'         >> /etc/php/*/fpm/pool.d/www.conf && \
    \
    chown -R www-data.www-data . && \
    \
    mkdir -p /etc/nginx/sites-enabled && \
    ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

COPY default.conf /etc/nginx/sites-available/default.conf


EXPOSE 5000

CMD service php7.3-fpm start && nginx -g 'daemon off;'
