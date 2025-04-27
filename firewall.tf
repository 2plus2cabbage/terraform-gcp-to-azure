# Creates a firewall rule to allow RDP traffic to the Windows VM
resource "google_compute_firewall" "cabbage_rdp" {
  name                  = "fw-${var.environment_name}-${var.location}-rdp"      # Name of the firewall rule
  network               = google_compute_network.cabbage_vpc.name               # VPC for the firewall rule
  allow {
    protocol            = "tcp"                                                 # Protocol for RDP
    ports               = ["3389"]                                              # Port for RDP
  }
  source_ranges         = [var.my_public_ip]                                    # Source IP for RDP access
  target_tags           = ["rdp"]                                               # Tag to apply the rule to
}

# Creates a firewall rule to allow all outbound traffic from the Windows VM
resource "google_compute_firewall" "cabbage_egress" {
  name                  = "fw-${var.environment_name}-${var.location}-egress"   # Name of the firewall rule
  network               = google_compute_network.cabbage_vpc.name               # VPC for the firewall rule
  allow {
    protocol            = "all"                                                 # All protocols for outbound traffic
  }
  direction             = "EGRESS"                                              # Direction of traffic
  destination_ranges    = ["0.0.0.0/0"]                                         # Allow all outbound destinations
}

# Creates a firewall rule to allow ICMP traffic from Azure subnet
resource "google_compute_firewall" "cabbage_icmp_from_azure" {
  name                    = "${local.firewall_rule_prefix}icmp-from-azure"      # Name of the firewall rule
  network                 = google_compute_network.cabbage_vpc.name             # VPC for the firewall rule
  allow {
    protocol              = "icmp"                                              # Protocol for ICMP
  }
  source_ranges           = [local.azure_subnet_cidr]                           # Source subnet (Azure) for ICMP traffic
}