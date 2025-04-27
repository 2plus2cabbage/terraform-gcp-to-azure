# Defines shared infrastructure for IPSEC connections in GCP
resource "google_compute_address" "gcp_vpn_ip" {
  name                     = "${local.vpn_ip_name_prefix}gcp"                             # Name of the static IP for the VPN Gateway
  region                   = var.region                                                   # GCP region for deployment
}

# Creates a VPN gateway in GCP for IPSEC connections
resource "google_compute_vpn_gateway" "gcp_vpn_gateway" {
  name                     = "${local.vpn_gateway_name_prefix}gcp"                        # Name of the VPN gateway
  network                  = google_compute_network.cabbage_vpc.id                        # VPC for the VPN gateway
  region                   = var.region                                                   # GCP region for deployment
}

# Forwarding rule for ESP protocol (IPSEC)
resource "google_compute_forwarding_rule" "gcp_vpn_rule_esp" {
  name                     = "${local.vpn_rule_name_prefix}esp"                           # Name of the forwarding rule for ESP
  region                   = var.region                                                   # GCP region for deployment
  ip_protocol              = "ESP"                                                        # Protocol for IPSEC (ESP)
  ip_address               = google_compute_address.gcp_vpn_ip.address                    # IP address for the forwarding rule
  target                   = google_compute_vpn_gateway.gcp_vpn_gateway.self_link         # Target VPN gateway
  depends_on               = [google_compute_vpn_gateway.gcp_vpn_gateway]                 # Ensure VPN gateway exists
}

# Forwarding rule for UDP 500 (IKE)
resource "google_compute_forwarding_rule" "gcp_vpn_rule_udp500" {
  name                     = "${local.vpn_rule_name_prefix}udp500"                        # Name of the forwarding rule for IKE
  region                   = var.region                                                   # GCP region for deployment
  ip_protocol              = "UDP"                                                        # Protocol for IKE (UDP)
  port_range               = "500"                                                        # Port for IKE
  ip_address               = google_compute_address.gcp_vpn_ip.address                    # IP address for the forwarding rule
  target                   = google_compute_vpn_gateway.gcp_vpn_gateway.self_link         # Target VPN gateway
  depends_on               = [google_compute_vpn_gateway.gcp_vpn_gateway]                 # Ensure VPN gateway exists
}

# Forwarding rule for UDP 4500 (NAT-T)
resource "google_compute_forwarding_rule" "gcp_vpn_rule_udp4500" {
  name                     = "${local.vpn_rule_name_prefix}udp4500"                       # Name of the forwarding rule for NAT-T
  region                   = var.region                                                   # GCP region for deployment
  ip_protocol              = "UDP"                                                        # Protocol for NAT-T (UDP)
  port_range               = "4500"                                                       # Port for NAT-T
  ip_address               = google_compute_address.gcp_vpn_ip.address                    # IP address for the forwarding rule
  target                   = google_compute_vpn_gateway.gcp_vpn_gateway.self_link         # Target VPN gateway
  depends_on               = [google_compute_vpn_gateway.gcp_vpn_gateway]                 # Ensure VPN gateway exists
}

# Outputs the GCP VPN Gateway public IP for IPSEC configuration
output "gcp_vpn_ip" {
  value                    = google_compute_address.gcp_vpn_ip.address                    # Public IP of the GCP VPN Gateway
  description              = "Public IP of the GCP VPN Gateway for IPSEC configuration"   # Description of the output
}