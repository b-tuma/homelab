#Proxmox Settings

variable "proxmox_host" {
  type    = string
  default = "host.example.org"
}

variable "proxmox_node"{
  type    = string
  default = "node"
}

variable "proxmox_user" {
  type    = string
  default = "proxmox"
}

variable "proxmox_password" {
  type    = string
  default = "password"
}

# VM Settings

variable "ssh_authorized_key" {
  type    = string
  default = "ssh-ed25519 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA me@mypc" 
}

variable "template_name" {
  type    = string
  default = "linux-template"
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = string
  default     = "cluster.local"
}

variable "worker_node_labels" {
  type        = map(list(string))
  description = "Map from worker names to lists of initial node labels"
  default     = {}
}

variable "worker_node_taints" {
  type        = map(list(string))
  description = "Map from worker names to lists of initial node taints"
  default     = {}
}

variable "network" {
  type = list(object({
    model = string
    bridge = string
    tag = number
    }))
  default = [{
    model = "virtio"
    bridge = "vmbr0"
    tag = -1
    }]
}

variable "root_size" {
  type = number
  default = 10
}

variable "storage_location" {
  type = string
  default = "local-lvm"
}

variable "cpu_cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

# Kubernetes Settings

variable "controllers_count" {
  type    = number
  default = 1
}

variable "controller_prefix" {
  type    = string
  default = "node-c"
}

variable "workers_count" {
  type    = number
  default = 1
}

variable "worker_prefix" {
  type    = string
  default = "node-w"
}

variable "api_server" {
  description = "Controller DNS name which resolves to a controller instance. Workers and kubeconfig's will communicate with this endpoint (e.g. cluster.example.com)"
  type        = string
  default = "unused.example.org"
}

variable "domain_name" {
  type        = string
}

variable "networking" {
  description = "Choice of networking provider (flannel or calico)"
  type        = string
  default     = "calico"
}

variable "network_mtu" {
  description = "CNI interface MTU (applies to calico only)"
  type        = number
  default     = 1480
}

variable "network_ip_autodetection_method" {
  description = "Method to autodetect the host IPv4 address (applies to calico only)"
  type        = string
  default     = "first-found"
}

variable "pod_cidr" {
  description = "CIDR IPv4 range to assign Kubernetes pods"
  type        = string
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
    CIDR IPv4 range to assign Kubernetes services.
    The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
    EOD
  type        = string
  default     = "10.3.0.0/16"
}

variable "cluster_name" {
  description = "Unique cluster name"
  type        = string
}

variable "controller_snippets" {
  type        = list(string)
  description = "Controller Butane snippets"
  default     = []
}

variable "worker_snippets" {
  type        = list(string)
  description = "Worker Butane snippets"
  default     = []
}

# optional

variable "enable_reporting" {
  description = "Enable usage or analytics reporting to upstreams (Calico)"
  type        = bool
  default     = false
}

variable "enable_aggregation" {
  description = "Enable the Kubernetes Aggregation Layer (defaults to false)"
  type        = bool
  default     = false
}