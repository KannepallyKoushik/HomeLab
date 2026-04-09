# Talos Template Module
# Creates Talos Linux templates in Proxmox for Kubernetes nodes

locals {
  # Talos versions and download URLs
  talos_version = var.talos_version
  
  # Template name includes version for easy identification
  template_name = "talos-${local.talos_version}-template"
}

