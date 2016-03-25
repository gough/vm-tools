#!/bin/sh

if [ "$#" -ne 2 ]; then
	/bin/echo "Usage: $0 base_vm_name new_vm_name"
	exit 1
fi

DATASTORE="datastore1"

BASE_VM_NAME=$1
if [ "$BASE_VM_NAME" = "debian" ]; then
	BASE_VM_NAME="debian-8.3"
elif [ "$BASE_VM_NAME" = "ubuntu" ]; then
	BASE_VM_NAME="ubuntu-server-14.04"
else
	/bin/echo "Base VM not found/not supported"
	exit 1
fi

# set base vm directory, vmx, and vmdk locations
BASE_VM_DIR="/vmfs/volumes/${DATASTORE}/.templates/${BASE_VM_NAME}"
BASE_VMX="${BASE_VM_DIR}/${BASE_VM_NAME}.vmx"
BASE_VMDK="${BASE_VM_DIR}/${BASE_VM_NAME}0.vmdk"

NEW_VM_NAME=$2
if [ ${#NEW_VM_NAME} -lt 2 ]; then
	/bin/echo "New VM name is too short"
	exit 1
fi

# set new vm directory (to be checked)
NEW_VM_DIR="/vmfs/volumes/${DATASTORE}/${NEW_VM_NAME}"
if [ -d "$NEW_VM_DIR" ]; then
	/bin/echo "Directory with new VM name already exists"
	exit 1
fi

# set new vmx and vmdk locations
NEW_VMX="${NEW_VM_DIR}/${NEW_VM_NAME}.vmx"
NEW_VMDK="${NEW_VM_DIR}/${NEW_VM_NAME}0.vmdk"

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

# change the following values
/bin/sed -i "s@scsi0:0.fileName.*@scsi0:0.fileName = \"${NEW_VM_NAME}0.vmdk\"@" $NEW_VMX
/bin/sed -i "s@scsi0:0.fileName.*@displayName = \"${NEW_VM_NAME}\"@" $NEW_VMX
/bin/sed -i 's/uuid.bios.*/uuid.action = "change"/' $NEW_VMX

# delete the following values
/bin/sed -i "/nvram/d" $NEW_VMX
/bin/sed -i '/sata0:0.fileName/d' $NEW_VMX
/bin/sed -i '/uuid.location/d' $NEW_VMX
/bin/sed -i '/vc.uuid/d' $NEW_VMX
/bin/sed -i '/sched.swap.derivedName/d' $NEW_VMX
/bin/sed -i '/migrate.hostlog/d' $NEW_VMX
/bin/sed -i '/scsi0.sasWWID/d' $NEW_VMX
/bin/sed -i '/ethernet0.generatedAddress/d' $NEW_VMX
/bin/sed -i '/vmci0.id/d' $NEW_VMX
/bin/sed -i '/tools.remindInstall/d' $NEW_VMX
/bin/sed -i '/vmotion.checkpointFBSize/d' $NEW_VMX
/bin/sed -i '/vmotion.checkpointSVGAPrimarySize/d' $NEW_VMX

/bin/echo "Done"

# copy vmdk
/bin/echo "Copying vmdk..."
/bin/vmkfstools -i "${BASE_VMDK}" "${NEW_VMDK}" -d thin

# done!
/bin/echo "Cloning complete! You may now add the VM through the ESXi interface."
