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

# Generate the uuid from BB_TASKHASH to ensure a new
# hash on each rebuild
def generate_image_uuid(d):
    import uuid

    base_hash = d.getVar("BB_TASKHASH", True)
    if base_hash is None:
        return None
    return str(uuid.UUID(base_hash[:32], version=4))

IMAGE_UUID ?= "${@generate_image_uuid(d)}"

def read_target_image_uuid(d):
    import os.path

    deploy_dir = d.getVar("DEPLOY_DIR_IMAGE")
    image_full_name = d.getVar("IMAGE_FULLNAME")
    uuid_file = f"{deploy_dir}/{image_full_name}.uuid.env"
    if not os.path.isfile(uuid_file):
        return None

    target_image_uuid = None
    with open(uuid_file, "r") as f:
       uuid_file_content = f.read()
       target_image_uuid = uuid_file_content.split('=')[1].strip(' \t\n\r').strip('\"')
    return target_image_uuid

TARGET_IMAGE_UUID = "${@read_target_image_uuid(d)}"

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
