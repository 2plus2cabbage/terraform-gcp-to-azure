# Defines the Terraform provider and version requirements for the GCP deployment
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}