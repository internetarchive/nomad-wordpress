#!/bin/bash -ex

( find /usr/share/nginx/html -maxdepth 0 -empty | grep -q . )  &&  (
  echo 'empty site hopefully starting out on persistent volume - installing wordpress'
  /app/fresh-install.sh
)

php-fpm -D
nginx -g 'daemon off;'
