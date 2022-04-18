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

INITRAMFS_RECIPE ?= "cip-core-initramfs"
do_wic_image[depends] += "${INITRAMFS_RECIPE}:do_build"
INITRD_IMAGE = "${INITRAMFS_RECIPE}-${DISTRO}-${MACHINE}.initrd.img"

inherit verity-img
inherit wic-swu-img

addtask do_wic_image after do_verity_image
