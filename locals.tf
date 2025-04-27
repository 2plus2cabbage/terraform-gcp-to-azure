# Defines local variables for naming conventions in GCP
locals {
  vpc_name                      = "vpc-${var.environment_name}-${var.location}-"           # Prefix for VPC name
  subnet_name_prefix            = "snet-${var.environment_name}-${var.location}-"          # Prefix for subnet name
  windows_name_prefix           = "vm-${var.environment_name}-${var.location}-windows-"    # Prefix for Windows VM name
  firewall_rule_prefix          = "fw-${var.environment_name}-${var.location}-"            # Prefix for firewall rules
  vpn_ip_name_prefix            = "vpnip-${var.environment_name}-${var.location}-"         # Prefix for VPN IP name
  vpn_gateway_name_prefix       = "vpngw-${var.environment_name}-${var.location}-"         # Prefix for VPN gateway name
  vpn_rule_name_prefix          = "vpnrule-${var.environment_name}-${var.location}-"       # Prefix for VPN rule name
  vpn_tunnel_name_prefix        = "vpntunnel-${var.environment_name}-${var.location}-"     # Prefix for VPN tunnel name
}