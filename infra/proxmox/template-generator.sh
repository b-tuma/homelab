#!/bin/bash
# Based on https://git.geco-it.net/GECO-IT-PUBLIC/fedora-coreos-proxmox

VMID="8000"
VMSTORAGE="local-lvm"
VMDISK_OPTIONS=",discard=on"
IMAGES_DIR=/var/lib/vz/images

STREAMS=stable
VERSION=3033.2.0

# Download Flatcar Linux
[[ ! -e ${IMAGES_DIR}/flatcar-linux-${VERSION}.qcow2 ]]&& {
    rm ${IMAGES_DIR}/flatcar-linux-*.qcow2 2> /dev/null
    echo "Download Flatcar Linux..."
    wget -q -P ${IMAGES_DIR} --show-progress https://${STREAMS}.release.flatcar-linux.net/amd64-usr/${VERSION}/flatcar_production_qemu_image.img.bz2
    bunzip2 ${IMAGES_DIR}/flatcar_production_qemu_image.img.bz2
    qemu-img create -f qcow2 -F qcow2 -b ${IMAGES_DIR}/flatcar_production_qemu_image.img ${IMAGES_DIR}/flatcar-linux-${VERSION}.qcow2
}

# Storage Type
echo -n "Get storage \"${VMSTORAGE}\" type... "
case "$(pvesh get /storage/${VMSTORAGE} --noborder --noheader | grep ^type | awk '{print $2}')" in
        dir|nfs|cifs|glusterfs|cephfs) VMSTORAGE_type="file"; echo "[file]"; ;;
        lvm|lvmthin|iscsi|iscsidirect|rbd|zfs|zfspool) VMSTORAGE_type="block"; echo "[block]" ;;
        *)
                echo "[unknown]"
                exit 1
        ;;
esac

# Import Flatcar Disk
if [[ "x${VMSTORAGE_type}" = "xfile" ]]
then
	vmdisk_name="${VMID}/vm-${VMID}-disk-0.qcow2"
	vmdisk_format="--format qcow2"
else
	vmdisk_name="vm-${VMID}-disk-0"
  vmdisk_format=""
fi

# Destroy current template
echo "Destroy current VM ${VMID}..."
qm destroy ${VMID} --destroy-unreferenced-disks 1 --purge 1 2> /dev/null

# Create VM
echo "Create Flarcar Linux VM ${VMID}"
qm create ${VMID} --name "flatcar-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk ${VMID} ${IMAGES_DIR}/flatcar-linux-${VERSION}.qcow2 ${VMSTORAGE} ${vmdisk_format}
qm set ${VMID} --scsihw virtio-scsi-pci --scsi0 ${VMSTORAGE}:${vmdisk_name}${VMDISK_OPTIONS}
qm set ${VMID} --boot c --bootdisk scsi0
qm set ${VMID} --serial0 socket --vga serial0
qm set ${VMID} --description "Flatcar Linux ${VERSION} Template"

# Convert VM Template
echo -n "Convert VM ${VMID} in Proxmox VM template... "
qm template ${VMID} &> /dev/null || true
echo "[done]"