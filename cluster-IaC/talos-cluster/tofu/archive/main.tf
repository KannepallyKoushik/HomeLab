# Configure the Proxmox provider

provider "proxmox" {
  # Configuration options
    endpoint = var.proxmox_endpoint
    insecure = true
    api_token = var.api_token_id
}

# ────────────────────────────────────────────────
# TALOS CONTROL PLANE VM
# ────────────────────────────────────────────────

resource "proxmox_virtual_environment_vm" "talos_cp_01" {
  name        = "talos-cp-01"
  description = "Managed by OpenTofu, Talos Linux Kubernetes Control Plane - No Cloud ISO boot"
  tags        = ["terraform","k8s", "talos", "controlplane"]
  node_name   = "k-pve-slim"
  vm_id       = 101

  # Boot configuration: ISO first, then disk
  boot {
    order = ["cdrom", "disk"]
  }

  # Attach the ISO as a CDROM
  cdrom {
    # datastore_id = "local"
    file_id      = "local:iso/${var.talos_iso_name}"
    # Some providers use references like `proxmox_virtual_environment_download_file.myiso.id`
  }

  # Disk definition: primary disk
  disk {
    datastore_id = "local-lvm"
    size         = 30   # in GiB
    interface    = "virtio0"
    iothread      = true
  }

  cpu {
    cores = 3
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

   initialization {
    # datastore_id = "local-zfs"
    ip_config {
      ipv4 {
        address = "${var.talos_cp_01_ip_addr}/24"
        gateway = var.default_gateway
      }
    }
    dns{
      servers = [var.dns_server]
    }
  }

  # Ensure autostart
  on_boot = true
}
