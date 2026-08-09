provider "docker" {
  # Leave unset to use the local Docker socket. Set docker_host when managing a
  # remote Docker daemon (for example, ssh://deploy@host).
  host = var.docker_host
}
