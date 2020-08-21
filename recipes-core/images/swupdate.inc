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

FILESEXTRAPATHS_prepend := "${THISDIR}/files/secure-boot:"

EXTRACT_PARTITIONS = "img4"
ROOTFS_PARTITION_NAME="img4.gz"

SRC_URI += "file://sw-description.tmpl"
TEMPLATE_FILES += "sw-description.tmpl"
TEMPLATE_VARS += "PN ROOTFS_PARTITION_NAME KERNEL_IMAGE INITRD_IMAGE"

SWU_ADDITIONAL_FILES += "${INITRD_IMAGE} ${KERNEL_IMAGE} ${ROOTFS_PARTITION_NAME}"
