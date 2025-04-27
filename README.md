<img align="right" width="150" src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/2plus2cabbage.png">

<img src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/gcp-to-azure.png" alt="gcp-to-azure" width="300" align="left">
<br clear="left">

# GCP-to-Azure Cross-Cloud Terraform Deployment

Deploys a Windows Server 2022 VM in Google Cloud Platform (GCP) with RDP, internet access, and an IPSEC VPN tunnel to a corresponding Windows VM in Azure for cross-cloud communication.

## Files
The project is split into multiple files to illustrate modularity and keep separate constructs distinct, making it easier to manage and understand.
- `main.tf`: Terraform provider block (`hashicorp/google`).
- `gcpprovider.tf`: GCP provider config with `project_id`, `region`, etc.
- `variables.tf`: Variables and locals for project, region, etc.
- `terraform.tfvars.template`: Template for sensitive/custom values; rename to `terraform.tfvars` and add your credentials.
- `locals.tf`: Local variables for naming conventions.
- `gcp-networking.tf`: VPC, subnet, and networking CIDRs.
- `azure-networking.tf`: Azure networking values (`azure_vpn_ip`, `azure_subnet_cidr`) for IPSEC.
- `firewall.tf`: Firewall rules for RDP (TCP 3389), ICMP, and outbound traffic.
- `routing-static.tf`: Route table for Azure subnet routing via the VPN tunnel.
- `ipsec-general.tf`: Shared IPSEC infrastructure (static IP, VPN Gateway, forwarding rules).
- `ipsec-azure.tf`: Azure-specific IPSEC resources (VPN tunnel).
- `windows.tf`: Windows VM, outputs public/private IPs.

## How It Works
- **Networking**: VPC and subnet provide connectivity. Route table routes to Azure subnet via the IPSEC tunnel.
- **Security**: Allows RDP from your IP, ICMP from the Azure subnet, and all outbound traffic.
- **Instance**: Windows Server 2022 VM with public IP, firewall disabled via `metadata`.
- **IPSEC Tunnel**: Establishes a VPN connection to an Azure project, allowing communication between the GCP and Azure Windows VMs.

## Prerequisites
- A GCP project with Compute Engine API enabled.
- A service account key, noting `project_id`, `region`, and path to the key file.
- A corresponding Azure project with IPSEC support, providing the `azure_vpn_ip` output.
- Terraform installed on your machine.
- Examples are demonstrated using Visual Studio Code (VSCode).

## Deployment Steps
1. Deploy the corresponding Azure project with IPSEC support to obtain the `azure_vpn_ip` output.
2. Update `terraform.tfvars` with GCP credentials, your public IP in `my_public_ip`, and the shared secret in `shared_secret_azure`.
3. Update `azure-networking.tf` with the actual `azure_vpn_ip` from the Azure project output.
4. Run `terraform init`, then (optionally) `terraform plan` to preview changes, then `terraform apply` (type `yes`).
5. Get the public IP from the `gcp_vm_public_ip` output on the screen, or run `terraform output gcp_vm_public_ip`, or check in the GCP Console under **Compute Engine > VM Instances**.
6. In the Azure project, update `gcp-networking.tf` with the GCP VPN Gateway IP (`gcp_vpn_ip` output) and run `terraform apply`.
7. Verify the tunnel in the GCP Console under **VPN > [vpn-tunnel-name]** (should show "Established").
8. In the GCP Console, go to **Compute Engine > VM Instances > [click running instance]**, click **Set Windows Password**, enter a username (e.g., `Administrator` or a new user), click **Set**, and note the generated password.
9. Use Remote Desktop to log in with the username and the generated password.
10. From the GCP VM, ping the Azure VM’s private IP (`azure_vm_private_ip` output) to confirm connectivity.
11. To remove all resources, run `terraform destroy` (type `yes`).

## Potential costs and licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation.
- It is important to fully understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.