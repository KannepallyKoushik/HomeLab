variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
  default     = "https://k-pve-slim:8006/" 
}

variable "api_token_id" {
  description = "Proxmox API token ID"
  type        = string
}

variable "cluster_name" {
  type    = string
  default = "homelab_talos"
}

variable "default_gateway" {
  description = "Default gateway for the Talos VMs"
  type        = string
  default     = "192.168.0.1"
}

variable "talos_cp_01_ip_addr" {
  description = "IP address for the Talos control plane VM"
  type        = string
  default     = "192.168.0.115"
}

variable "talos_iso_name" {
  description = "Name of the Talos ISO file"
  type        = string
  default     = "no-cloud-1-11-1-amd64.iso"
}

variable "dns_server" {
  description = "DNS server for the Talos VMs"
  type        = string
  default     = "192.168.0.200"
}