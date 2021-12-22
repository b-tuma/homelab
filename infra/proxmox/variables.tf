variable "ssh_public_key" {
    type    = string
    default = "ssh-rsa AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA me@mypc" 
}

variable "domain_name" {
    type    = string
}

variable "kubeconfig_path" {
  type    = string
  default = "/home/user/.kube/config" 
}

# Proxmox Settings

variable "proxmox_host" {
    type    = string
    default = "host"
}

variable "proxmox_node"{
    type    = string
    default = "node"
}

variable "proxmox_user" {
    type    = string
    sensitive = true
    default = "proxmox@auth"
}

variable "proxmox_password" {
    type    = string
    sensitive = true
    default = "12345678-1234-1234-1234-0123456789ab"
}