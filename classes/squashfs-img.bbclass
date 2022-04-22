#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2021-2022
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT
#

SQUASHFS_IMAGE_FILE = "${IMAGE_FULLNAME}.squashfs.img"

IMAGER_INSTALL += "squashfs-tools"

SQUASHFS_EXCLUDE_DIRS ?= ""
SQUASHFS_CONTENT ?= "${PP_ROOTFS}"
SQUASHFS_CREATION_ARGS ?= ""

python __anonymous() {
    exclude_directories = d.getVar('SQUASHFS_EXCLUDE_DIRS').split()
    if len(exclude_directories) == 0:
        return
    # Use wildcard to exclude only content of the directory.
    # This allows to use the directory as a mount point.
    args = " -wildcards"
    for dir in exclude_directories:
        args += " -e {dir}/* ".format(dir=dir)
    d.appendVar('SQUASHFS_CREATION_ARGS', args)
}

do_squashfs_image[dirs] = "${DEPLOY_DIR_IMAGE}"
do_squashfs_image() {
    rm -f '${DEPLOY_DIR_IMAGE}/${SQUASHFS_IMAGE_FILE}'

    image_do_mounts

    sudo chroot "${BUILDCHROOT_DIR}" /bin/mksquashfs  \
        "${SQUASHFS_CONTENT}" "${PP_DEPLOY}/${SQUASHFS_IMAGE_FILE}" \
        ${SQUASHFS_CREATION_ARGS}
}
addtask do_squashfs_image before do_image after do_image_tools do_excl_directories
