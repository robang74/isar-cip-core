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
inherit wic-swu-img

addtask do_verity_image after do_${SECURE_IMAGE_FSTYPE}_image
addtask do_wic_image after do_verity_image
