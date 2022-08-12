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

inherit swupdate
inherit read-only-rootfs

IMAGE_INSTALL += " swupdate"
IMAGE_INSTALL += " swupdate-handler-roundrobin"

ROOTFS_PARTITION_NAME = "${IMAGE_FULLNAME}.wic.p4.gz"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://sw-description.tmpl"
TEMPLATE_FILES += "sw-description.tmpl"

TEMPLATE_VARS += "ROOTFS_PARTITION_NAME"

SWU_ADDITIONAL_FILES += "linux.efi ${ROOTFS_PARTITION_NAME}"
