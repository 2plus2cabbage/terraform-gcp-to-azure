# Defines Azure networking values for IPSEC connection
locals {
    azure_peer_ip           = "172.178.45.14"      # The public IP of the Azure VPN Gateway
    azure_subnet_cidr       = "10.4.1.0/24"        # The private network on the Azure side
}