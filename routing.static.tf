# Creates a route to direct traffic from GCP to Azure subnet via the VPN tunnel
resource "google_compute_route" "route_to_azure" {
  name                   = "${local.vpn_tunnel_name_prefix}route-to-azure"  # Name of the route
  network                = google_compute_network.cabbage_vpc.id            # VPC for the route
  dest_range             = local.azure_subnet_cidr                          # Destination range (Azure subnet)
  next_hop_vpn_tunnel    = google_compute_vpn_tunnel.gcp_to_azure_tunnel.id # Next hop VPN tunnel
  priority               = 1000                                             # Route priority
  depends_on             = [google_compute_vpn_tunnel.gcp_to_azure_tunnel]  # Ensure tunnel exists
}