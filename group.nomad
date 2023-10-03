task "db" {
  driver = "docker"
  lifecycle {
    sidecar = true
    hook = "prestart"
  }
  config {
    # future versions can make bootstrap user setup from WP container challenging, tracey 9/2023
    image = "docker.io/bitnami/mariadb:11.0.3"
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
