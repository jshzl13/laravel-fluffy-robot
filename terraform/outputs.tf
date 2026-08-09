output "application_url" {
  description = "URL for the Laravel application."
  value       = "http://localhost:${var.app_port}"
}

output "network_name" {
  description = "Docker network containing the application services."
  value       = docker_network.laravel.name
}
