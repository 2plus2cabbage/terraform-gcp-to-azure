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
- **Note**: Cloud providers regularly change their console interfaces without notice. Steps outlined today may not apply exactly tomorrow.

## Procedural Note
Either the Azure or GCP project can be deployed first to obtain the first VPN IP; this example starts with Azure. The deployment must follow a specific order due to dependencies on VPN Gateway IPs:
- First, deploy the Azure project to obtain the `azure_vpn_ip` output in step 3.
- Then, in this GCP project, update `terraform.tfvars` with the `azure_vpn_ip`, deploy this project, and note the `gcp_vpn_ip` output in step 4.
- Finally, update `terraform.tfvars` in the Azure project with the `gcp_vpn_ip`, and redeploy the Azure project in step 5 to complete the tunnel setup.
Ensure the shared secret (`shared_secret_gcp` in Azure, `shared_secret_azure` in GCP) matches in both projects' `terraform.tfvars`.

## Deployment Steps
1. Update `terraform.tfvars` with GCP credentials, your public IP in `my_public_ip`, the shared secret in `shared_secret_azure`, and the Azure VPN IP in `azure_vpn_ip` (obtained from the Azure project’s `azure_vpn_ip` output).
2. Run `terraform init`, then (optionally) `terraform plan` to preview changes, then `terraform apply` (type `yes`).
3. Get the public IP from the `gcp_vm_public_ip` output on the screen, or run `terraform output gcp_vm_public_ip`, or check in the GCP Console under **Compute Engine > VM Instances**. Note the `gcp_vpn_ip` output for use in the Azure project.
4. In the Azure project, update `terraform.tfvars` with the GCP VPN Gateway IP (`gcp_vpn_ip` output) in `gcp_vpn_ip`, ensure `shared_secret_gcp` matches the shared secret from GCP, and run `terraform apply`.
5. Verify the tunnel in the GCP Console under **VPC Network > Cloud VPN** (should show "Established").
6. In the GCP Console, go to **Compute Engine > VM Instances > [click running instance]**, click **Set Windows Password**, enter a username (e.g., `adminuser`), click **Set**, and note the generated password.
7. Use Remote Desktop to log in to the GCP VM with the username and the generated password, using the public IP from the `gcp_vm_public_ip` output.
8. From the GCP VM, ping the Azure VM’s private IP (`azure_vm_private_ip` output) to confirm connectivity; then from the Azure VM, ping the GCP VM’s private IP (`gcp_vm_private_ip` output) to confirm bidirectional connectivity. If the ping from GCP to Azure fails, verify the Windows Firewall is disabled on the GCP VM by running `netsh advfirewall show allprofiles` in PowerShell (it should show `State: OFF`). If enabled, disable it with `netsh advfirewall set allprofiles state off` and check for system policies re-enabling it.
9. To remove all resources, run `terraform destroy` (type `yes`).

## Potential costs and licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation.
- It is important to fully understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.