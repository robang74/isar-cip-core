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

ROOTFS_PARTITION_NAME = "${IMAGE_FULLNAME}.wic.img.p4.gz"

SRC_URI += "file://sw-description.tmpl"
TEMPLATE_FILES += "sw-description.tmpl"

TEMPLATE_VARS += "ROOTFS_PARTITION_NAME"

SWU_ADDITIONAL_FILES += "linux.signed.efi ${ROOTFS_PARTITION_NAME}"
