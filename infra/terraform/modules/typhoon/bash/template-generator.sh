#!/bin/bash
# Based on https://git.geco-it.net/GECO-IT-PUBLIC/fedora-coreos-proxmox
# Download Flatcar Linux
[[ ! -e ${images_dir}/flatcar-linux-${stream}-${version}.qcow2 ]]&& {
    rm ${images_dir}/flatcar-linux-*.qcow2 2> /dev/null
    echo "Download Flatcar Linux..."
    wget -q -P ${images_dir} --show-progress https://${stream}.release.flatcar-linux.net/amd64-usr/${version}/flatcar_production_qemu_image.img.bz2
    bunzip2 ${images_dir}/flatcar_production_qemu_image.img.bz2
    qemu-img create -f qcow2 -F qcow2 -b ${images_dir}/flatcar_production_qemu_image.img ${images_dir}/flatcar-linux-${stream}-${version}.qcow2
}

# Storage Type
echo -n "Get storage \"${vmstorage}\" type... "
case "$(pvesh get /storage/${vmstorage} --noborder --noheader | grep ^type | awk '{print $2}')" in
        dir|nfs|cifs|glusterfs|cephfs) VMSTORAGE_type="file"; echo "[file]"; ;;
        lvm|lvmthin|iscsi|iscsidirect|rbd|zfs|zfspool) VMSTORAGE_type="block"; echo "[block]" ;;
        *)
                echo "[unknown]"
                exit 1
        ;;
esac

# Import Flatcar Disk
if [[ "x$${VMSTORAGE_type}" = "xfile" ]]
then
	vmdisk_name="${vmid}/vm-${vmid}-disk-0.qcow2"
	vmdisk_format="--format qcow2"
else
	vmdisk_name="vm-${vmid}-disk-0"
        vmdisk_format=""
fi

# Destroy current template
echo "Destroy current VM ${vmid}..."
qm destroy ${vmid} --destroy-unreferenced-disks 1 --purge 1 2> /dev/null

# Create VM
echo "Create Flarcar Linux VM ${vmid}"
qm create ${vmid} --name ${template_name} --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk ${vmid} ${images_dir}/flatcar-linux-${stream}-${version}.qcow2 ${vmstorage} $${vmdisk_format}
qm set ${vmid} --scsihw virtio-scsi-pci --scsi0 ${vmstorage}:$${vmdisk_name}${vmdisk_options}
qm set ${vmid} --boot c --bootdisk scsi0
qm set ${vmid} --serial0 socket --vga serial0
qm set ${vmid} --description "Flatcar Linux ${version} Template"

# Convert VM Template
echo -n "Convert VM ${vmid} in Proxmox VM template... "
qm template ${vmid} &> /dev/null || true
echo "[done]"