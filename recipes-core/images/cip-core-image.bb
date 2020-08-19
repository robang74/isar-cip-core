#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2019
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#
# SPDX-License-Identifier: MIT
#

inherit image

ISAR_RELEASE_CMD = "git -C ${LAYERDIR_cip-core} describe --tags --dirty --always --match 'v[0-9].[0-9]*'"
DESCRIPTION = "CIP Core image"

IMAGE_INSTALL += "customizations"

# for swupdate
EXTRACT_PARTITIONS = "img4"
ROOTFS_PARTITION_NAME="img4.gz"

SRC_URI += "file://sw-description.tmpl"
TEMPLATE_FILES += "sw-description.tmpl"
TEMPLATE_VARS += "PN ROOTFS_PARTITION_NAME"

SWU_ADDITIONAL_FILES += "linux.signed.efi ${ROOTFS_PARTITION_NAME}"
