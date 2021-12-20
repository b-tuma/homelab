variable "ssh_public_key" {
    type    = string
    default = "ssh-rsa AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA me@mypc" 
}

variable "domain_name" {
    type    = string
}

variable "alpine_template" {
    type = string
    default = "alpine-ssh.tar.gz"
}

variable "template_name" {
    type = string
    default = "flatcar-template"
}

variable "kubeconfig_file" {
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