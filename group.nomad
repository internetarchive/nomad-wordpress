task "NOMAD_VAR_SLUG-db" {
  driver = "docker"
  lifecycle {
    sidecar = true
    hook = "prestart"
  }
  config {
    image = "docker.io/bitnami/mariadb"
    ports = ["db"]
    volumes = ["/pv/${var.CI_PROJECT_PATH_SLUG}-db:/bitnami/mariadb"]
  }

  template {
    data = <<EOH
{{key "NOMAD_VAR_SLUG"}}

MARIADB_DATABASE=bitnami_wordpress
MARIADB_USER=wp_user
EOH
    destination = "secrets/file.env"
    env         = true
  }
}
