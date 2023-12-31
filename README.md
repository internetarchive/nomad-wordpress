# WordPress with Nomad

This sets up a blank WP blog, leveraging
[HinD](https://github.com/internetarchive/hind)
(Hashistack-IN-Docker)

It deploys two containers in a single nomad `job`, one with `nginx` and `wordpress`, and a `mariadb` database container.

# Unit testing of the two containers used
- https://hub.docker.com/r/bitnami/wordpress-nginx
- https://hub.docker.com/r/bitnami/mariadb

## Startup help
- https://wordpress.org/documentation/article/reset-your-password/#through-mysql-command-line

Starting from scratch w/ a `nomad` deploy and two containers doing a "dance" to get each bootstrapped can be a pain.
You will likely want to fire up 2 containers manually the first time to get them to setup properly,
using passed in "Persistent Volumes" for the DB & config setup to persist.
```sh
# figure out your password ;-)

PORT=33066
sudo docker run --rm -it --name deleteme1 --pull=always --net=host \
  -p ${PORT?}:3306 \
  -e MARIADB_PASSWORD=${PW?} \
  -e MARIADB_ROOT_PASSWORD=${PW?} \
  -e MARIADB_DATABASE=bitnami_wordpress \
  -e MARIADB_USER=wp_user \
  -v /pv/internetarchive-wordpress-db:/bitnami/mariadb \
  bitnami/mariadb

# run in another terminal
sudo docker run --rm -it --name deleteme2 --pull=always --net=host \
  -e MARIADB_PASSWORD=${PW?} \
  -e MARIADB_ROOT_PASSWORD=${PW?} \
  -e WORDPRESS_DATABASE_PASSWORD=${PW?} \
  -e WORDPRESS_DATABASE_HOST=$(hostname) \
  -e WORDPRESS_DATABASE_PORT_NUMBER=${PORT?} \
  -e WORDPRESS_DATABASE_USER=wp_user \
  -v /pv/internetarchive-wordpress:/bitnami/wordpress \
  bitnami/wordpress-nginx:6
```
