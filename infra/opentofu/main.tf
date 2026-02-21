terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = true

  # API auth via environment variables:
  #   PROXMOX_VE_API_TOKEN='root@pam!opentofu=<secret>'

  ssh {
    agent    = true
    username = "root"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.node_name
  url          = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
  file_name    = "ubuntu-24.04-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_file" "cloud_init" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
      username       = var.username
      ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_file)))
    })

    file_name = "cloud-init-vm.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "cluster" {
  for_each = var.vms

  node_name = var.node_name
  vm_id     = each.value.vm_id
  name      = each.key

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.storage
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    size         = each.value.disk_size
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${each.value.ip_address}/${var.cidr}"
        gateway = var.gateway
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init.id
  }

  operating_system {
    type = "l26"
  }

  on_boot = true
}
