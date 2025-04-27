# Creates a Windows Server 2022 VM instance in GCP
resource "google_compute_instance" "windows_instance" {
  name                          = "${local.windows_name_prefix}001"                                                         # Name of the Windows VM
  machine_type                  = "e2-standard-2"                                                                           # Machine type (compute resources)
  zone                          = "${var.region}-b"                                                                         # Zone for deployment (e.g., us-central1-b)
  boot_disk {
    initialize_params {
      image                     = "projects/windows-cloud/global/images/family/windows-2022"                                # Windows Server 2022 image
    }
  }
  network_interface {
    subnetwork                  = google_compute_subnetwork.cabbage_subnet.name                                             # Subnetwork for the VM
    access_config {                                                                                                         # Assigns a public IP - Empty block assigns an ephemeral public IP for external access
    }
  }
  tags                          = ["rdp"]                                                                                   # Tags for firewall rules
  metadata                      = {
    windows-startup-script-ps1  = "netsh advfirewall set allprofiles state off"                                             # Disables firewall on boot
  }
}

# Outputs the public IP of the Windows VM for RDP access
output "gcp_vm_public_ip" {
  value                         = google_compute_instance.windows_instance.network_interface[0].access_config[0].nat_ip     # Public IP address of the VM
  description                   = "Public IP of the GCP Windows VM"                                                         # Description of the output
}

# Outputs the private IP of the Windows VM for internal networking
output "gcp_vm_private_ip" {
  value                         = google_compute_instance.windows_instance.network_interface[0].network_ip                  # Private IP address of the VM
  description                   = "Private IP of the GCP Windows VM"                                                        # Description of the output
}