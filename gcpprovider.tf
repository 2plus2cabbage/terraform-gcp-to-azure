# Configures the GCP provider with authentication details for Terraform to manage GCP resources
provider "google" {
  project                   = var.project_id
  region                    = var.region
  credentials               = file(var.credentials_file)
}