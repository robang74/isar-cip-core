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

SECURE_IMAGE_FSTYPE ?= "squashfs"

inherit ${SECURE_IMAGE_FSTYPE}-img

VERITY_IMAGE_TYPE = "${SECURE_IMAGE_FSTYPE}"

INITRAMFS_RECIPE ?= "cip-core-initramfs"
do_wic_image[depends] += "${INITRAMFS_RECIPE}:do_build"
INITRD_IMAGE = "${INITRAMFS_RECIPE}-${DISTRO}-${MACHINE}.initrd.img"

inherit verity-img
inherit wic-img
inherit compress_swupdate_rootfs
inherit swupdate-img

SOURCE_IMAGE_FILE = "${WIC_IMAGE_FILE}"

addtask do_verity_image after do_${SECURE_IMAGE_FSTYPE}_image
addtask do_wic_image after do_verity_image
addtask do_compress_swupdate_rootfs after do_wic_image
addtask do_swupdate_image after do_compress_swupdate_rootfs
