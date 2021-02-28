FROM nginx
LABEL maintainer="tracey <tracey AT archive DOT org>"

ENV DEBIAN_FRONTEND noninteractive

ENV DOCUMENT_ROOT /usr/share/nginx/html

# Install nginx php-fpm php-pdo unzip curl
RUN apt-get update  && \
    apt-get -yqq install php5-fpm unzip curl apt-utils php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl  && \
    rm -rf ${DOCUMENT_ROOT}/*  && \
    # setup WP
    curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzvf /wordpress.tar.gz --strip-components=1 --directory ${DOCUMENT_ROOT} && \
    # setup sqlite
    curl -o sqlite-plugin.zip https://downloads.wordpress.org/plugin/sqlite-integration.1.7.zip && \
    unzip sqlite-plugin.zip -d ${DOCUMENT_ROOT}/wp-content/plugins/ && \
    rm sqlite-plugin.zip && \
    cp ${DOCUMENT_ROOT}/wp-content/plugins/sqlite-integration/db.php ${DOCUMENT_ROOT}/wp-content && \
    cp ${DOCUMENT_ROOT}/wp-config-sample.php ${DOCUMENT_ROOT}/wp-config.php
    # nginx config
    sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
    sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 10m/" /etc/nginx/nginx.conf && \
    sed -i -e "s|include /etc/nginx/conf.d/\*.conf|include /etc/nginx/sites-enabled/\*|g" /etc/nginx/nginx.conf && \
    # php-fpm config
    sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 10M/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 10M/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf && \
    sed -i -e "s/;listen.mode = 0660/listen.mode = 0666/g" /etc/php5/fpm/pool.d/www.conf

RUN chown -R www-data.www-data ${DOCUMENT_ROOT}

COPY default /etc/nginx/sites-available/default
RUN mkdir -p /etc/nginx/sites-enabled && \
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

EXPOSE 80
EXPOSE 443

CMD service php5-fpm start && nginx -g 'daemon off;'
