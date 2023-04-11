# WordPress with Nomad

This sets up a blank WP blog, leveraging
[HinD](https://github.com/internetarchive/hind)
(Hashistack-IN-Docker)

It deploys two containers in a single nomad `job`, one with `nginx` and `wordpress`, and a `mariadb` database container.

# Unit testing of the two containers used
- https://hub.docker.com/r/bitnami/wordpress-nginx
- https://hub.docker.com/r/bitnami/mariadb


```sh
docker run --rm -it \
  --net=host \
  -e MARIADB_ROOT_PASSWORD=kimchi \
  -e MARIADB_PASSWORD=kimchi \
  -e MARIADB_DATABASE=bitnami_wordpress \
  -e MARIADB_USER=wp_user \
  docker.io/bitnami/mariadb


docker run --rm -it \
  --net=host \
  -e WORDPRESS_DATABASE_HOST=XXXX \
  -e WORDPRESS_DATABASE_PORT_NUMBER=3306 \
  -e WORDPRESS_DATABASE_PASSWORD=kimchi \
  -e WORDPRESS_DATABASE_USER=wp_user \
  bitnami/wordpress-nginx:6
```
