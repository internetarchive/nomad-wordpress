FROM php:fpm-alpine
LABEL maintainer="tracey <tracey AT archive DOT org>"

ENV DEBIAN_FRONTEND noninteractive

ENV DOCUMENT_ROOT /usr/share/nginx/html
WORKDIR           /usr/share/nginx/html

# https://wordpress.org/plugins/memcached/#installation   xxx
#   https://scotty-t.com/2012/01/20/wordpress-memcached/  xxx

RUN apk add bash zsh git nginx imagemagick-dev unzip wget php-curl php-gd php-intl php-pear \
        php-imap php-pspell php-tidy php-xmlrpc php-xsl php8-sqlite3 && \
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
    cd - && \
    rm -rf /tmp/php-memcached && \
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
    # config nginx and php-fpm to allow up to 10MB file postings
    INI=/usr/local/etc/php/php.ini && \
    cp /usr/local/etc/php/php.ini-production $INI && \
    sed -i -e "s/^upload_max_filesize.*/upload_max_filesize = 10M/" $INI && \
    sed -i -e "s/^post_max_size.*/post_max_size = 10M/"             $INI && \
    sed -i -e "s/client_max_body_size 1m/client_max_body_size 10m/"  /etc/nginx/nginx.conf && \
    # (weird:)
    mkdir -p /run/nginx && \
    \
    chown -R www-data.www-data . && \
    \
    # gotta get compatible w/ php v8
    PDO=/usr/share/nginx/html/wp-content/plugins/sqlite-integration/pdoengine.class.php && \
    perl -i -pe 's/param\{([^}]+)\}/param[$1]/' $PDO && \
    perl -i -pe 's/public function query.*/public function query(string \$query, ?int \$fetchMode = null, mixed ...\$fetchModeArgs) {/' $PDO

COPY default.conf /etc/nginx/http.d/


EXPOSE 5000

CMD sh -c "php-fpm -D && nginx -g 'daemon off;'"
