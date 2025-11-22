#
# PREREQUISITES!
# sudo mkdir -p -m777 /pv/internetarchive-nomad-wordpress-db
#
task "db" {
  driver = "docker"
  lifecycle {
    sidecar = true
    hook = "prestart"
  }
  resources {
    cpu        = 500
    memory     = 2048 # 2GB RAM big limit esp. for initial DB setup
    memory_max = 8000 # hard limit
  }
  config {
    image = "mysql:8.0"
    ports = ["db"]
    volumes = ["/pv/${var.CI_PROJECT_PATH_SLUG}-db:/var/lib/mysql"]

    # Workaround a nomad orchestration of mysql container issue with mysql container use of
    # 'ioctl' for 'autodetection of TTY or not?' on startup.
    # So we'll just do the init ourselves, when needed, and then do the normal mysqld start.
    command = "bash"
    args = [
      "-c",
      <<EOF
# Initialize DB if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "Initializing MySQL data directory..."
  mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
fi

# Create init SQL file
cat > /tmp/init.sql <<EOSQL
CREATE DATABASE IF NOT EXISTS \`demo-db\`;
CREATE USER IF NOT EXISTS 'demo-user'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`demo-db\`.* TO 'demo-user'@'%';
FLUSH PRIVILEGES;
EOSQL

# Start mysqld
exec mysqld \
  --user=mysql \
  --datadir=/var/lib/mysql \
  --default-authentication-plugin=mysql_native_password \
  --init-file=/tmp/init.sql
EOF
    ]
  }

  template {
    data = <<EOH
{{key "NOMAD_VAR_SLUG"}}

MYSQL_DATABASE=demo-db
MYSQL_USER=demo-user
MYSQL_RANDOM_ROOT_PASSWORD=1
EOH
    destination = "secrets/file.env"
    env         = true
  }
}


# task "perms" {
#   driver = "docker"
#   lifecycle {
#     sidecar = false
#     hook = "prestart"
#   }
#   config {
#     # setup a few dirs we need
#     image = "alpine"
#     volumes = ["/pv/${var.CI_PROJECT_PATH_SLUG}:/pv"]
#     command = "sh"
#     args    = [
#       "-cx",
# <<EOF
# set +e;
# mkdir -p  /pv/wp-content/themes;
# chmod 777 /pv/wp-content/themes;
# chmod ugo+rwX -R /pv/wp-content/plugins;
# exit 0;
# EOF
#     ]
#   }
# }
