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
    template_name = var.template_name
    storage_location = "local-lvm"
    root_size = 10
    cpu_cores = 2
    memory = 4096

    # Cluster Settings
    cluster_name = "nookium"
    controller_prefix = "node-c"
    worker_prefix = "node-w"
    domain_name = var.domain_name
    controllers_count = 1
    workers_count = 0
    pod_cidr = "10.50.64.0/24"
    service_cidr = "10.50.68.0/24"
    networking = "calico"

    controller_snippets = [file("./snippets/controller.yaml")]
    worker_snippets = [file("./snippets/worker.yaml")]
}

resource "local_file" "kubeconfig-nookium" {
  depends_on = [module.nookium]
  content  = module.nookium.kubeconfig-admin
  file_permission = 0600
  filename = var.kubeconfig_path
}

resource "time_sleep" "wait_2_minutes" {
  depends_on = [local_file.kubeconfig-nookium]

  create_duration = "120s"
}

# SSH
locals {
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
}

# Flux
data "flux_install" "main" {
  target_path = var.target_path
}

data "flux_sync" "main" {
  target_path = var.target_path
  url         = "ssh://git@github.com/${var.github_owner}/${var.repository_name}.git"
  branch      = var.branch
}

# Kubernetes
resource "kubernetes_namespace" "flux_system" {
  depends_on = [time_sleep.wait_2_minutes]
  provider = kubernetes.k8s
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubernetes_secret" "main" {
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = data.flux_sync.main.secret
    namespace = data.flux_sync.main.namespace
  }

  data = {
    identity       = tls_private_key.main.private_key_pem
    "identity.pub" = tls_private_key.main.public_key_pem
    known_hosts    = local.known_hosts
  }
}

# GitHub
data "github_repository" "main" {
  name = var.repository_name
}

resource "tls_private_key" "main" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "main" {
  title      = "nookium-cluster"
  repository = data.github_repository.main.name
  key        = tls_private_key.main.public_key_openssh
  read_only  = true
}

# resource "github_repository_file" "install" {
#   repository = data.github_repository.main.name
#   file       = data.flux_install.main.path
#   content    = data.flux_install.main.content
#   branch     = var.branch
# }

# resource "github_repository_file" "sync" {
#   repository = data.github_repository.main.name
#   file       = data.flux_sync.main.path
#   content    = data.flux_sync.main.content
#   branch     = var.branch
# }

# resource "github_repository_file" "kustomize" {
#   repository = data.github_repository.main.name
#   file       = data.flux_sync.main.kustomize_path
#   content    = data.flux_sync.main.kustomize_content
#   branch     = var.branch
# }