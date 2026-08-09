locals {
  resource_prefix = var.project_name
}

resource "docker_network" "laravel" {
  name   = "${local.resource_prefix}_network"
  driver = "bridge"
}

resource "docker_volume" "mysql_data" {
  name = "${local.resource_prefix}_mysql_data"

  # Database data should never be removed as a side effect of a normal apply.
  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_volume" "storage" {
  name = "${local.resource_prefix}_storage"
}

resource "docker_volume" "bootstrap_cache" {
  name = "${local.resource_prefix}_bootstrap_cache"
}

resource "docker_image" "app" {
  name         = var.app_image
  keep_locally = false
}

resource "docker_image" "mysql" {
  name         = "mysql:8.0"
  keep_locally = false
}

resource "docker_image" "redis" {
  name         = "redis:alpine"
  keep_locally = false
}

resource "docker_container" "mysql" {
  name    = "${local.resource_prefix}_db"
  image   = docker_image.mysql.image_id
  restart = "unless-stopped"

  env = [
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
  ]

  volumes {
    volume_name    = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }

  networks_advanced {
    name    = docker_network.laravel.name
    aliases = ["db"]
  }
}

resource "docker_container" "redis" {
  name    = "${local.resource_prefix}_redis"
  image   = docker_image.redis.image_id
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.laravel.name
    aliases = ["redis"]
  }
}

resource "docker_container" "app" {
  name    = "${local.resource_prefix}_app"
  image   = docker_image.app.image_id
  restart = "unless-stopped"

  ports {
    internal = 80
    external = var.app_port
  }

  # The image intentionally does not include src/.env. Supply the runtime
  # settings explicitly so the service resolves its Docker network aliases.
  env = [
    "APP_ENV=production",
    "APP_DEBUG=false",
    "APP_KEY=${var.app_key}",
    "APP_URL=http://localhost:${var.app_port}",
    "DB_CONNECTION=mysql",
    "DB_HOST=db",
    "DB_PORT=3306",
    "DB_DATABASE=${var.mysql_database}",
    "DB_USERNAME=root",
    "DB_PASSWORD=${var.mysql_root_password}",
    "REDIS_HOST=redis",
    "REDIS_PORT=6379",
  ]

  volumes {
    volume_name    = docker_volume.storage.name
    container_path = "/var/www/html/storage"
  }

  volumes {
    volume_name    = docker_volume.bootstrap_cache.name
    container_path = "/var/www/html/bootstrap/cache"
  }

  networks_advanced {
    name    = docker_network.laravel.name
    aliases = ["app"]
  }

  depends_on = [
    docker_container.mysql,
    docker_container.redis,
  ]
}
