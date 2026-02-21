variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
  default     = "https://192.168.0.100:8006"
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "home"
}

variable "gateway" {
  description = "Network gateway"
  type        = string
  default     = "192.168.0.1"
}

variable "cidr" {
  description = "CIDR prefix length"
  type        = string
  default     = "24"
}

variable "storage" {
  description = "Proxmox storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "ssh_public_key_file" {
  description = "Path to SSH public key file for cloud-init"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "username" {
  description = "Default user created by cloud-init"
  type        = string
  default     = "cereal"
}

variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    vm_id      = number
    ip_address = string
    cores      = number
    memory     = number
    disk_size  = number
  }))
  default = {
    home = {
      vm_id      = 200
      ip_address = "192.168.0.200"
      cores      = 2
      memory     = 4096
      disk_size  = 32
    }
    hello = {
      vm_id      = 201
      ip_address = "192.168.0.201"
      cores      = 2
      memory     = 4096
      disk_size  = 32
    }
  }
}
