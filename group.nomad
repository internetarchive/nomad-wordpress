task "db" {
  driver = "docker"
  lifecycle {
    sidecar = true
    hook = "prestart"
  }
  config {
    image = "mysql:8.0"
    ports = ["db"]
    volumes = ["/pv/${var.CI_PROJECT_PATH_SLUG}-db:/var/lib/mysql"] # xxxx


    # workaround a nomad orchestration of mysql container issue with mysql container use of
    # 'ioctl' for 'autodetection of TTY or not?' on startup
    tty = true
    tmpfs = ["/tmp", "/run"]
    command = "sh"
    args = [
      "-c",
      "/usr/local/bin/docker-entrypoint.sh mysqld || ( cat /var/lib/mysql/*err; sleep 300 )"
      # "/usr/local/bin/docker-entrypoint.sh mysqld --default-authentication-plugin=mysql_native_password || sleep 300"
      # "exec /usr/local/bin/docker-entrypoint.sh mysqld --default-authentication-plugin=mysql_native_password"
    ]
  }

  # xxx
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
