variable "talos_version" {
  description = "Talos Linux version to use"
  type        = string
  default     = "1.11.1"  
}

variable "proxmox_node" {
  description = "Proxmox node name where the template will be created"
  type        = string
  default     = "k-pve-slim"
}