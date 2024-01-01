# WordPress with Nomad

This sets up a blank WP blog, leveraging
[HinD](https://github.com/internetarchive/hind)
(Hashistack-IN-Docker)

It deploys two containers in a single nomad `job`, one with `nginx` and `wordpress`, and a `mariadb` database container.

## Startup help
To login from the website and do final setup, the easiest way is from https://wordpress.org/documentation/article/reset-your-password/#through-wp-cli

ssh into your main container (non DB) deployment container then:
```sh
wp user list
wp user update 1 --user_pass=$MARIADB_PASSWORD
```

Once you've updated the user password on the back-end, you should be able to login via the
/wp-admin
URL and update any WP version, plugins, themes, etc.

You can also upgrade WP on the backend via ssh into the main container via:
```sh
wp core update
```

- Also see the `sql` convenience shell function that should be loaded by default when popping into
  the running wordpress/nginx container.  (see [.bashrc](.bashrc))


## Unit testing of the two containers used
- https://hub.docker.com/r/bitnami/wordpress-nginx
- https://hub.docker.com/r/bitnami/mariadb

Starting from scratch w/ a `nomad` deploy and two containers doing a "dance" to get each bootstrapped can sometimes be a pain.
If they don't eventually start up, you may want to fire up 2 containers manually to get a proper setup,
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
  bitnami/mariadb:11.0.3

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
