#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2021
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
SQUASHFS_CREATION_ARGS ?= " "
# Generate squashfs filesystem image
python __anonymous() {
    exclude_directories = (d.getVar('SQUASHFS_EXCLUDE_DIRS') or "").split()
    if len(exclude_directories) == 0:
        return
    # use wildcard to exclude only content of the the directory
    # this allows to use the directory as a mount point
    args = " -wildcards"
    for dir in exclude_directories:
        args += " -e {dir}/* ".format(dir=dir)
    d.appendVar('SQUASHFS_CREATION_ARGS', args)
}

do_squashfs_image() {
    rm -f '${DEPLOY_DIR_IMAGE}/${SQUASHFS_IMAGE_FILE}'

    image_do_mounts

    sudo chroot "${BUILDCHROOT_DIR}" /bin/mksquashfs  \
        "${SQUASHFS_CONTENT}" "${PP_DEPLOY}/${SQUASHFS_IMAGE_FILE}" \
        ${SQUASHFS_CREATION_ARGS}
}
addtask do_squashfs_image before do_image after do_image_tools do_excl_directories
