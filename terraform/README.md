# Terraform

This directory manages the project's Docker runtime: the Laravel application,
MySQL, Redis, the private bridge network, and persistent Docker volumes.

## Prerequisites

- Terraform 1.6 or newer
- Docker Engine running, with access to its socket

## Run locally

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set a strong mysql_root_password and a real app_key.
# Generate an app key with: docker compose run --rm app php artisan key:generate --show
terraform init
terraform plan
terraform apply
```

The application is available at the `application_url` output (by default,
`http://localhost:8000`). MySQL and Redis are private to the Docker network;
they are intentionally not published on host ports.

Use `TF_VAR_mysql_root_password` and `TF_VAR_app_key` instead of a local tfvars
file when deploying from CI. The local `terraform.tfvars`, Terraform state, and
provider lock file are ignored by Git. The MySQL volume is protected from
`terraform destroy` to avoid accidental data loss; remove that lifecycle
protection only after a deliberate backup and teardown.
