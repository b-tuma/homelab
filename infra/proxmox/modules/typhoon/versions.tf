# Terraform version and plugin versions

terraform {
    required_version = ">= 0.13.0, < 2.0.0"
    required_providers {
        template = "~> 2.2"
        null = ">= 3.1"
        
        proxmox = {
            source  = "telmate/proxmox"
            version = "~> 2.9.1"
        }

        ct = {
            source = "poseidon/ct"
            version = "~> 0.9"
        }
    }
}

provider "proxmox" {
  pm_api_url      = "https://${var.proxmox_host}:8006/api2/json"
  pm_user         = "${var.proxmox_user}@pam"
  pm_password     = var.proxmox_password
  pm_tls_insecure = true
}