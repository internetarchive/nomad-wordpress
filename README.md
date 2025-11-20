# WordPress with Nomad

This sets up a blank WP blog, leveraging
[HinD](https://github.com/internetarchive/hind)
(Hashistack-IN-Docker)

It deploys two containers in a single nomad `job`, one with `apache2` and `wordpress`, and a `mysql` database container.


## Startup help
To login from the website and do final setup, the easiest way is to visit the site and step through the prompts.

If you run into troubles you can try
https://wordpress.org/documentation/article/reset-your-password/#through-wp-cli

ssh into your main container (non DB) deployment container then:
```sh
wp user list
wp user update 1 --user_pass=...
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
- https://hub.docker.com/_/wordpress
- https://hub.docker.com/_/mysql

Starting from scratch w/ a `nomad` deploy and two containers doing a "dance" to get each bootstrapped can sometimes be a pain.
If they don't eventually start up, you may want to fire up 2 containers manually to get a proper setup.

```sh
# figure out your password ;-)

podman run --rm -it --name db --net=bridge -p 3306:3306 \
  -e MYSQL_DATABASE=demo-db \
  -e MYSQL_USER=demo-user \
  -e MYSQL_RANDOM_ROOT_PASSWORD=1 \
  -e MYSQL_PASSWORD=666ggg666 \
  mysql:8.0

podman run --rm -it --name wp --net=bridge -p 8080:80 \
  -e WORDPRESS_DB_NAME=demo-db \
  -e WORDPRESS_DB_USER=demo-user \
  -e WORDPRESS_DB_PASSWORD=666ggg666 \
  -e WORDPRESS_DB_HOST=165.22.247.210:3306 \
  wordpress sh -c '/usr/local/bin/docker-entrypoint.sh apache2-foreground'
```
