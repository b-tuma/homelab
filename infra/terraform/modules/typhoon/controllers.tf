# Flatcar Linux Controller

# Generate Proxmox VM for controllers
resource "proxmox_vm_qemu" "controllers" {
    depends_on = [
      null_resource.proxmox_controller_configs,
    ]
    
    count = var.controllers_count

    name = "kube-controller-${count.index + 1}"
    desc = "Flatcar Linux - Kubernetes Controller ${count.index + 1}"
    target_node = var.proxmox_node
    clone = var.template_name

    onboot = true
    tablet = false

    # The args parameter will not work without some edits to Proxmox code.
    # See more in proxmox-args-workaround.md
    args = "-fw_cfg name=opt/com.coreos/config,file=/tmp/controller_ignition_${count.index + 1}.ign"
    agent = 1
    cores = var.cpu_cores
    cpu = "host"
    memory = var.memory
    scsihw    = "virtio-scsi-pci"
    bootdisk  = "scsi0"
    
    disk {
        slot     = 0
        size     = "${var.root_size}G"
        type     = "scsi"
        storage  = var.storage_location
        iothread = 1
    }

    dynamic "network" {
        for_each = var.network
        content {
            model = network.value["model"]
            bridge = network.value["bridge"]
            tag = network.value["tag"]
        }
    }

    timeouts {
        create = "5m"
        delete = "1m"
    }
}

# Send Ignition file to Proxmox server
resource "null_resource" "proxmox_controller_configs" {
  count = var.controllers_count

  connection {
    type = "ssh"
    user = var.proxmox_user
    password = var.proxmox_password
    host = var.proxmox_host
  }

  provisioner "file" {
    content = data.ct_config.controller-ignitions.*.rendered[count.index]
    destination = "/tmp/controller_ignition_${count.index + 1}.ign"
  }
}

# Controller config converted to Ignition
data "ct_config" "controller-ignitions" {
    count = var.controllers_count

    content = data.template_file.controller-configs.*.rendered[count.index]
    strict = true
    snippets = var.controller_snippets
}

# Controller Butane config
data "template_file" "controller-configs" {
  count = var.controllers_count

  template = file("${path.module}/cl/controller.yaml")
  vars = {
    hostname = "${var.controller_prefix}${count.index + 1}"
    domain_name = var.domain_name
    etcd_initial_cluster = join(",", data.template_file.etcds.*.rendered)
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix = var.cluster_domain_suffix
    ssh_authorized_key = var.ssh_authorized_key
  }
}

data "template_file" "etcds" {
  count = var.controllers_count
  template = "$${etcd}=https://$${domain}:2380"

  vars = {
    etcd   = "${var.controller_prefix}${count.index + 1}"
    domain = "${var.controller_prefix}${count.index + 1}.${var.domain_name}"
  }
}