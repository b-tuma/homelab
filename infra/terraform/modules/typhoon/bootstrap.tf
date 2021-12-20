# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=37f45cb28be2188befb5304794ba312cd8048fab"

  cluster_name                    = var.cluster_name
  #api_servers                     = [var.api_server]
  api_servers                     = ["${var.controller_prefix}1.${var.domain_name}"]
  etcd_servers                    = [
      for num in range(var.controllers_count):
      "${var.controller_prefix}${num + 1}.${var.domain_name}"
  ]
  networking                      = var.networking
  network_mtu                     = var.network_mtu
  network_ip_autodetection_method = var.network_ip_autodetection_method
  pod_cidr                        = var.pod_cidr
  service_cidr                    = var.service_cidr
  cluster_domain_suffix           = var.cluster_domain_suffix
  enable_reporting                = var.enable_reporting
  enable_aggregation              = var.enable_aggregation
}