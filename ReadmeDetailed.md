# Detailed Deployment Guide: GCP-to-Azure Cross-Cloud Terraform Deployment

This guide provides step-by-step instructions to deploy a Windows Server 2022 VM in Google Cloud Platform (GCP) with RDP, internet access, and an IPSEC VPN tunnel to a corresponding Windows VM in Azure for cross-cloud communication.

## Prerequisites
Before starting, ensure you have the following:
- A GCP account with a project.
- GCP credentials: `project_id` and `credentials_file` (path to the service account key JSON file).
- A corresponding Azure project with IPSEC support, providing the `azure_vpn_ip` output.
- Terraform installed on your machine.
- Visual Studio Code (VSCode) or another editor for modifying files.
- Your public IP address for RDP access (e.g., `203.0.113.5/32`; find it using a service like `whatismyipaddress.com`).
- **Note**: Cloud providers regularly change their console interfaces without notice. Steps outlined today may not apply exactly tomorrow.

## Deployment Steps

### Step 1: Update `terraform.tfvars` with GCP Credentials and Configuration
1. Open the `terraform.tfvars` file in your editor (e.g., VSCode).
2. Update the following fields with your information:
   - `project_id`: Replace `"<your-project-id>"` with your GCP project ID (e.g., `my-gcp-project-123`).
   - `region`: Replace `"<your-region>"` with your GCP region (e.g., `us-central1`).
   - `credentials_file`: Replace `"<path-to-credentials-file>"` with the path to your GCP credentials JSON file (e.g., `/path/to/credentials.json`).
   - `environment_name`: Replace `"<your-environment-name>"` with your environment name (e.g., `cabbage`).
   - `location`: Replace `"<your-location>"` with your location identifier (e.g., `uscentral1`).
   - `my_public_ip`: Replace `"<your-public-ip>"` with your public IP (e.g., `203.0.113.5/32`).
   - `shared_secret_azure`: Replace `"<your-shared-secret>"` with the shared secret for the IPSEC tunnel (e.g., `abc123...`).
   - `azure_vpn_ip`: Replace `"<azure-vpn-ip>"` with the Azure VPN Gateway IP (e.g., `172.178.45.14`, obtained from the Azure project’s `azure_vpn_ip` output).
3. Save the file.

### Step 2: Initialize and Deploy the GCP Project
1. Open a terminal in the GCP project directory.
2. Run `terraform init` to initialize the Terraform working directory and download providers. This should take about 30 seconds.
3. (Optional) Run `terraform plan` to preview the changes Terraform will make. Review the output to ensure it looks correct (should take 15-30 seconds).
4. Run `terraform apply` to deploy the GCP resources. Type `yes` when prompted to confirm. This will create the VPC, subnet, VM, and VPN resources (takes about 2-5 minutes).

### Step 3: Retrieve the GCP VM Public IP
1. After deployment, Terraform will output several values. Note the `gcp_vm_public_ip` value (e.g., `34.123.45.67`) for RDP access.
2. Alternatively, find the public IP in the GCP Console:
   - Go to **Compute Engine > VM instances**.
   - Locate the instance named `vm-<environment_name>-<location>-windows-001` (e.g., `vm-cabbage-uscentral1-windows-001`).
   - Note the "External IP" in the details pane.

### Step 4: Retrieve the GCP VM Initial Password
1. Go to the GCP Console: **Compute Engine > VM instances**.
2. Select the instance named `vm-<environment_name>-<location>-windows-001`.
3. Click **Set Windows Password**, enter a username (e.g., `adminuser`), click **Set**, and note the generated password for RDP access.

### Step 5: Update and Redeploy the Azure Project with the GCP VPN IP
1. In the Azure project directory, open the `terraform.tfvars` file in your editor.
2. Update the `gcp_vpn_ip` field with the `gcp_vpn_ip` value output from step 2 (e.g., `35.196.116.13`).
3. Save the file.
4. Follow the Azure project’s deployment guide to update the `terraform.tfvars` file with the shared secret and redeploy with `terraform apply`.

### Step 6: Verify the Tunnel
1. Go to the GCP Console: **VPC Network > Cloud VPN**.
2. Select the connection named `vpn-<environment_name>-<location>-to-azure`.
3. Confirm the tunnel status is "Established".

### Step 7: Connect to the GCP VM via RDP
1. Open your Remote Desktop client (e.g., Microsoft Remote Desktop).
2. Enter the public IP of the GCP VM from the `gcp_vm_public_ip` output (e.g., `34.123.45.67`).
3. Use the username and password retrieved in step 4.
4. Connect to the VM.

### Step 8: Verify Connectivity Between GCP and Azure VMs
1. From the GCP VM, open Command Prompt or PowerShell.
2. Ping the Azure VM’s private IP (e.g., `terraform output azure_vm_private_ip` in the Azure project, such as `10.4.1.10`).
3. In the Azure project, connect to the Azure VM via RDP using the public IP from the `azure_vm_public_ip` output.
4. From the Azure VM, ping the GCP VM’s private IP (e.g., `terraform output gcp_vm_private_ip` in the GCP project, such as `10.2.1.10`).
5. Confirm bidirectional connectivity is successful. If the ping from GCP to Azure fails, verify the Windows Firewall is disabled on the GCP VM by running `netsh advfirewall show allprofiles` in PowerShell (it should show `State: OFF`). If enabled, disable it with `netsh advfirewall set allprofiles state off` and check for system policies re-enabling it.

### Step 9: Clean Up Resources
1. In the terminal, run `terraform destroy` to remove all resources. Type `yes` to confirm (takes about 1-2 minutes).
2. Repeat this step in the Azure project to clean up its resources.

## Potential Costs and Licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation.
- It is important to understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.