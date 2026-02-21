terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }
}

provider "proxmox" {
  # endpoint = "https://proxmox.cereal.box:8006"
  # Configure via environment variables:
  #   PROXMOX_VE_ENDPOINT
  #   PROXMOX_VE_USERNAME
  #   PROXMOX_VE_PASSWORD
}
