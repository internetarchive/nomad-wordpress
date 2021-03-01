#!/bin/bash -ex


# wipes out (BE CAREFUL!) a WP directory and starts it over


cd /usr/share/nginx/html


# start docroot clean
rm -rfv *


# setup WP
curl -s https://wordpress.org/latest.tar.gz | tar xzf - --strip-components=1


# start with stock WP config
cp wp-config-sample.php  wp-config.php
# assume https only
# https://wordpress.org/support/article/administration-over-ssl/#using-a-reverse-proxy
sed -i -e "s|<?php|<?php define('FORCE_SSL_ADMIN',true); \$_SERVER['HTTPS']='on';|" wp-config.php


# setup sqlite
curl -o sq.zip https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip
unzip sq.zip -d wp-content/plugins/
rm sq.zip

cp wp-content/plugins/sqlite-integration/db.php  wp-content
# get very old plugin compatible w/ php v8
PDO=wp-content/plugins/sqlite-integration/pdoengine.class.php
perl -i -pe 's/param\{([^}]+)\}/param[$1]/' $PDO
perl -i -pe 's/public function query.*/public function query(string \$query, ?int \$fetchMode = null, mixed ...\$fetchModeArgs) {/' $PDO


chown -R www-data.www-data .
