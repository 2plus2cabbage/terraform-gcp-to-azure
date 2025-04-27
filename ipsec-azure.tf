# Creates a VPN tunnel from GCP to Azure
resource "google_compute_vpn_tunnel" "gcp_to_azure_tunnel" {
  name                     = "${local.vpn_tunnel_name_prefix}to-azure"                  # Name of the VPN tunnel
  region                   = var.region                                                 # GCP region for deployment
  target_vpn_gateway       = google_compute_vpn_gateway.gcp_vpn_gateway.self_link       # Target VPN gateway
  peer_ip                  = local.azure_peer_ip                                        # Azure VPN Gateway public IP
  shared_secret            = var.shared_secret_azure                                    # Shared secret for IPSEC
  ike_version              = 2                                                          # IKE version for IPSEC
  local_traffic_selector   = [google_compute_subnetwork.cabbage_subnet.ip_cidr_range]   # Local subnet (GCP) for traffic
  remote_traffic_selector  = [local.azure_subnet_cidr]                                  # Remote subnet (Azure) for traffic
  depends_on               = [
    google_compute_forwarding_rule.gcp_vpn_rule_esp,
    google_compute_forwarding_rule.gcp_vpn_rule_udp500,
    google_compute_forwarding_rule.gcp_vpn_rule_udp4500
  ]
}