# Send and execute template generator
resource "null_resource" "proxmox_template" {
  connection {
    type = "ssh"
    user = var.proxmox_user
    password = var.proxmox_password
    host = var.proxmox_host
  }

  provisioner "file" {
    content = data.template_file.template_script.rendered
    destination = "/tmp/template-generator.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/template-generator.sh",
      "/tmp/template-generator.sh",
    ]
  }
}

# Proxmox template generator script
data "template_file" "template_script" {
  template = file("${path.module}/bash/template-generator.sh")
  vars = {
    version = var.flatcar_version
    stream = var.flatcar_stream
    template_name=var.template_name
    vmid = "8000"
    vmstorage = "local"
    vmdisk_options = ",discard=on"
    images_dir = "/var/lib/vz/template/qemu"
  }
}