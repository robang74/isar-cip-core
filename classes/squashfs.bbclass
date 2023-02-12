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

IMAGER_INSTALL:squashfs += "squashfs-tools"

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

IMAGE_CMD:squashfs[depends] = "${PN}:do_transform_template"
IMAGE_CMD:squashfs() {
    ${SUDO_CHROOT} /bin/mksquashfs \
        '${SQUASHFS_CONTENT}' '${IMAGE_FILE_CHROOT}' \
        -noappend ${SQUASHFS_CREATION_ARGS}
}
