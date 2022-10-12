#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2020-2022
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#  Jan Kiszka <jan.kiszka@siemens.com>
#
# SPDX-License-Identifier: MIT
#

inherit rootfs
inherit image

def generate_image_uuid(d):
    import uuid

    base_hash = d.getVar("BB_TASKHASH", True)
    if base_hash is None:
        return None
    return str(uuid.UUID(base_hash[:32], version=4))

IMAGE_UUID ?= "${@generate_image_uuid(d)}"

do_generate_image_uuid[vardeps] += "IMAGE_UUID"
do_generate_image_uuid[depends] = "buildchroot-target:do_build"
do_generate_image_uuid[dirs] = "${DEPLOY_DIR_IMAGE}"
do_generate_image_uuid() {
    sudo sed -i '/^IMAGE_UUID=.*/d' '${IMAGE_ROOTFS}/etc/os-release'
    echo "IMAGE_UUID=\"${IMAGE_UUID}\"" | \
        sudo tee -a '${IMAGE_ROOTFS}/etc/os-release'

    echo "TARGET_IMAGE_UUID=\"${IMAGE_UUID}\"" \
        > "${DEPLOY_DIR_IMAGE}/${IMAGE_FULLNAME}.uuid.env"
}
addtask generate_image_uuid before do_image after do_rootfs
