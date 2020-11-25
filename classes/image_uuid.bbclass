#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2020
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT
#

def generate_image_uuid(d):
    import uuid

    base_hash = d.getVar("BB_TASKHASH", True)
    if base_hash is None:
        return None
    return str(uuid.UUID(base_hash[:32], version=4))

IMAGE_UUID ?= "${@generate_image_uuid(d)}"

do_generate_image_uuid[vardeps] += "IMAGE_UUID"
do_generate_image_uuid[depends] = "buildchroot-target:do_build"
do_generate_image_uuid() {
    sudo sed -i '/^IMAGE_UUID=.*/d' '${IMAGE_ROOTFS}/etc/os-release'
    echo "IMAGE_UUID=\"${IMAGE_UUID}\"" | \
        sudo tee -a '${IMAGE_ROOTFS}/etc/os-release'
    image_do_mounts

    # update initramfs to add uuid
    sudo chroot '${IMAGE_ROOTFS}' update-initramfs -u
}
addtask generate_image_uuid before do_copy_boot_files after do_rootfs_install
