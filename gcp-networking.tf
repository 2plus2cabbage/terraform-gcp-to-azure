# Creates a virtual private cloud (VPC) to host the subnet and resources
resource "google_compute_network" "cabbage_vpc" {
  name                      = "${local.vpc_name}1020016"                # Name of the VPC
  auto_create_subnetworks   = false                                     # Disable auto-creation of subnets
}

# Creates a subnet within the VPC for the Windows VM
resource "google_compute_subnetwork" "cabbage_subnet" {
  name                      = "${local.subnet_name_prefix}1021024"      # Name of the subnet
  ip_cidr_range             = "10.2.1.0/24"                             # CIDR range for the subnet
  region                    = var.region                                # GCP region for deployment
  network                   = google_compute_network.cabbage_vpc.id     # VPC for the subnet
}