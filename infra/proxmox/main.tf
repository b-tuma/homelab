# Proxmox
module "nookium" {
    source = "./modules/typhoon"
    # Proxmox Settings
    proxmox_host = var.proxmox_host
    proxmox_node = var.proxmox_node
    proxmox_user = var.proxmox_user
    proxmox_password = var.proxmox_password

    # VM Settings
    ssh_authorized_key = var.ssh_public_key
    storage_location = "local-lvm"
    root_size = 10
    cpu_cores = 2
    memory = 4096

    # Cluster Settings
    cluster_name = "nookium"
    controller_prefix = "k8s-c"
    worker_prefix = "k8s-w"
    domain_name = var.domain_name
    controllers_count = 1
    workers_count = 0
    pod_cidr = "10.50.64.0/24"
    service_cidr = "10.50.68.0/24"
    networking = "calico"
    macid = "0A"
    api_server = "k8s.home.mansures.net"
    coredns = false

    controller_snippets = [file("./snippets/controller.yaml")]
    worker_snippets = [file("./snippets/worker.yaml")]
}

resource "local_file" "kubeconfig-nookium" {
  depends_on = [module.nookium]
  content  = module.nookium.kubeconfig-admin
  file_permission = 0600
  filename = var.kubeconfig_path
}