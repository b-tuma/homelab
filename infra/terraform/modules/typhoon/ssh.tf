locals {
  # format assets for distribution
  assets_bundle = [
    # header with the unpack location
    for key, value in module.bootstrap.assets_dist :
    format("##### %s\n%s", key, value)
  ]
}

# Secure copy assets to controllers. Activates kubelet.service
resource "null_resource" "copy-controller-secrets" {
  count = var.controllers_count
  
  depends_on = [
    resource.proxmox_vm_qemu.controllers,
    resource.proxmox_vm_qemu.workers,
    module.bootstrap,
  ]

  connection {
    type    = "ssh"
    host    = "${var.controller_prefix}${count.index + 1}.${var.domain_name}"
    user    = "core"
    timeout = "15m"
    agent = true
  }

  provisioner "file" {
    content     = module.bootstrap.kubeconfig-kubelet
    destination = "/home/core/kubeconfig"
  }

  provisioner "file" {
    content     = join("\n", local.assets_bundle)
    destination = "/home/core/assets"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo /opt/bootstrap/layout",
    ]
  }
}

# Secure copy kubeconfig to all workers. Activates kubelet.service
resource "null_resource" "copy-worker-secrets" {
  count = var.workers_count

  depends_on = [
    resource.proxmox_vm_qemu.controllers,
    resource.proxmox_vm_qemu.workers,
  ]

  connection {
    type    = "ssh"
    host    = "${var.worker_prefix}${count.index + 1}.${var.domain_name}"
    user    = "core"
    timeout = "15m"
    agent = true
  }

  provisioner "file" {
    content     = module.bootstrap.kubeconfig-kubelet
    destination = "/home/core/kubeconfig"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
    ]
  }
}

# # Connect to a controller to perform one-time cluster bootstrap.
resource "null_resource" "bootstrap" {
  # Without depends_on, this remote-exec may start before the kubeconfig copy.
  # Terraform only does one task at a time, so it would try to bootstrap
  # while no Kubelets are running.
  depends_on = [
    null_resource.copy-controller-secrets,
    null_resource.copy-worker-secrets,
  ]

  connection {
    type    = "ssh"
    host    = "${var.controller_prefix}1.${var.domain_name}"
    user    = "core"
    timeout = "15m"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start bootstrap",
    ]
  }
}
