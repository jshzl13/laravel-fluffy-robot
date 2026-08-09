variable "project_name" {
  description = "Prefix used for Docker resources managed by this configuration."
  type        = string
  default     = "laravel"
}

variable "docker_host" {
  description = "Docker daemon endpoint. Null uses Docker's local default socket."
  type        = string
  default     = null
  nullable    = true
}

variable "app_image" {
  description = "Laravel application image to run. Pin this to a release tag or digest for production."
  type        = string
  default     = "ghcr.io/jshzl13/laravel-fluffy-robot:main"
}

variable "app_key" {
  description = "Laravel APP_KEY, normally generated with `php artisan key:generate --show`."
  type        = string
  sensitive   = true
}

variable "app_port" {
  description = "Host TCP port for the Laravel application."
  type        = number
  default     = 8000

  validation {
    condition     = var.app_port > 0 && var.app_port < 65536
    error_message = "app_port must be a valid TCP port."
  }
}

variable "mysql_database" {
  description = "Database created when MySQL is first initialized."
  type        = string
  default     = "laravel"
}

variable "mysql_root_password" {
  description = "MySQL root password. Provide this through TF_VAR_mysql_root_password or terraform.tfvars."
  type        = string
  sensitive   = true
}
