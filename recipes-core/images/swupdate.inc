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

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

EXTRACT_PARTITIONS = "${IMAGE_FULLNAME}.wic.img.p4"
ROOTFS_PARTITION_NAME="${IMAGE_FULLNAME}.wic.img.p4.gz"

SRC_URI += "file://sw-description.tmpl"
TEMPLATE_FILES += "sw-description.tmpl"
TEMPLATE_VARS += "PN ROOTFS_PARTITION_NAME KERNEL_IMAGE INITRD_IMAGE"

SWU_ADDITIONAL_FILES += "${INITRD_IMAGE} ${KERNEL_IMAGE} ${ROOTFS_PARTITION_NAME}"
