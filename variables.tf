# Defines variables for GCP project configuration
variable "project_id" {
  type        = string
  description = "GCP project ID, found in GCP console under Project Info"
}

variable "region" {
  type        = string
  description = "GCP region for deployment"
}

variable "credentials_file" {
  type        = string
  description = "Path to the GCP service account key JSON file"
}

variable "environment_name" {
  type        = string
  description = "Name for your environment, used in resource naming"
}

variable "location" {
  type        = string
  description = "Location identifier, used in resource naming"
}

variable "my_public_ip" {
  type        = string
  description = "Your public IP for RDP access"
}

variable "shared_secret_azure" {
  type        = string
  description = "Shared secret for GCP-to-Azure IPSEC tunnel"
  sensitive   = true
}

variable "azure_vpn_ip" {
  type        = string
  description = "The public IP of the Azure VPN Gateway"
}