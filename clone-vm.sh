#!/bin/sh

DATASTORE="datastore1"

BASE_VM_NAME="debian"
BASE_VM_DIR="/vmfs/volumes/${DATASTORE}/${BASE_VM_NAME}"
BASE_VMX="${BASE_VM_DIR}/${BASE_VM_NAME}.vmx"
BASE_VMDK="${BASE_VM_DIR}/${BASE_VM_NAME}0.vmdk"

NEW_VM_NAME=$1
NEW_VM_DIR="/vmfs/volumes/${DATASTORE}/${NEW_VM_NAME}"
NEW_VMX="${NEW_VM_DIR}/${NEW_VM_NAME}.vmx"
NEW_VMDK="${NEW_VM_DIR}/${NEW_VM_NAME}0.vmdk"

if [ "$#" -ne 1 ]; then
	/bin/echo "Usage: $0 new_vm_name"
	exit 1
fi

if [ ${#NEW_VM_NAME} -lt 2 ]; then
	/bin/echo "New VM name is too short"
	exit 1
fi

if [ -d "$NEW_VM_DIR" ]; then
	/bin/echo "Directory with new VM name already exists"
	exit 1
fi

# create directory
/bin/echo -n "Creating directory... "
/bin/mkdir "${NEW_VM_DIR}"
/bin/echo "Done"

# copy vmx
/bin/echo -n "Copying vmx... "
/bin/cp "${BASE_VMX}" "${NEW_VMX}"
/bin/echo "Done"

# modify vmx
/bin/echo -n "Modifying vmx... "
/bin/sed -i 's@nvram = "debian.nvram"@@' $NEW_VMX
/bin/sed -i "s@scsi0:0.fileName = \"debian0.vmdk\"@scsi0:0.fileName = \"${NEW_VM_NAME}0.vmdk\"@" $NEW_VMX
/bin/sed -i 's@sata0:0.fileName = "/vmfs/volumes/554a73c9-25c6050f-21ee-308d99cc9950/iso/debian-8.3.0-amd64-CD-1.iso"@@' $NEW_VMX
/bin/sed -i "s@displayName = \"debian\"@displayName = \"${NEW_VM_NAME}\"@" $NEW_VMX
/bin/sed -i 's@sched.swap.derivedName = "/vmfs/volumes/554a73c9-25c6050f-21ee-308d99cc9950/debian/debian-7fedc08d.vswp"@@' $NEW_VMX
/bin/sed -i 's@migrate.hostlog = "./debian-7fedc08d.hlog"@@' $NEW_VMX
/bin/echo "Done"

# copy vmdk
/bin/echo "Copying vmdk..."
/bin/vmkfstools -i "${BASE_VMDK}" "${NEW_VMDK}" -d thin

# done!
/bin/echo "Cloning complete! You may now add the VM through the ESXi interface."
