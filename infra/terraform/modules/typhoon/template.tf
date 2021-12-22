# Send and execute template generator
resource "null_resource" "proxmox_template" {
  connection {
    type = "ssh"
    user = var.proxmox_user
    password = var.proxmox_password
    host = var.proxmox_host
  }

  provisioner "file" {
    content = data.template_file.template_script.*.rendered
    destination = "/tmp/template-generator.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /tmp/template-generator.sh",
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
    vmstorage = "local-lvm"
    vmdisk_options = ",discard=on"
    images_dir = "/var/lib/vz/images"
  }
}