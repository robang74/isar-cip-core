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

EXTRACT_PARTITIONS = "img4"
ROOTFS_PARTITION_NAME="img4.gz"

SRC_URI += "file://sw-description.tmpl"
TEMPLATE_FILES += "sw-description.tmpl"

TEMPLATE_VARS += "PN ROOTFS_PARTITION_NAME"

SWU_DESCRIPTION_FILE = "sw-description"
SWU_ADDITIONAL_FILES += "linux.signed.efi ${ROOTFS_PARTITION_NAME}"
