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
inherit image_uuid
ISAR_RELEASE_CMD = "git -C ${LAYERDIR_cip-core} describe --tags --dirty --always --match 'v[0-9].[0-9]*'"
DESCRIPTION = "CIP Core image"

IMAGE_INSTALL += "customizations"

# for swupdate
SWU_DESCRIPTION ??= "swupdate"
include ${SWU_DESCRIPTION}.inc
