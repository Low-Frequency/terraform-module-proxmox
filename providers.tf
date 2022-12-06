terraform {
  required_version = ">= 1.2.8"
  required_providers {
      proxmox = {
        source  = "Telmate/proxmox"
        version = ">= 2.9.11"
      }
  }
}
