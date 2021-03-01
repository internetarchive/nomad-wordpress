# WordPress

## wordpress using sqlite (instead of mysql) and nginx - all in one container

using:
- alpine linux
- php-fpm
- nginx
- php v8
- sqlite3

It starts out "blank" and you will want to visit the site and setup the admin account immediately.

### database files
- `/usr/share/nginx/html/wp-content/database/.ht.sqlite` - main file
- `/usr/share/nginx/html/wp-content/database/.ht.sqlite-journal` - during a large import

### persistent data
If you are deploying to Kubernetes, Nomad, docker-composer or similar - you should ensure this directory is using a [Persistent Volume](https://kubernetesbyexample.com/pv):
- `/usr/share/nginx/html/`
  - however, the only necessarily persistent 2 file/dirs are:
    - `/usr/share/nginx/html/wp-config.php`
    - `/usr/share/nginx/html/wp-content`
      - includes sqlite DB file
      - includes all themes and plugins
- Local Storage is a good simple option that both [k3s](https://k3s.io/) and [nomad](https://gitlab.com/internetarchive/nomad) can use.

### importing from another WP site
- you can `tgz` up any non-public theme or plugin subfolders, and then `tar xzvf my-plugin.tgz` inside the `wp-content/themes/` or  `wp-content/plugins/` folders
- you can export one or more `.xml` file using WordPress exporter
- you can `zip` them for smaller sizes for import (there are often maximum post sizes)
- import one or more `.xml` or `.xml.zip` files to your wordpress site, via the admin section [import] [wordpress], eg:
https://HOSTNAME/wp-admin/admin.php?import=wordpress
