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

inherit image_uuid
inherit swupdate
inherit read-only-rootfs

IMAGE_INSTALL += " swupdate"
IMAGE_INSTALL += " swupdate-handler-roundrobin"

ROOTFS_PARTITION_NAME = "${IMAGE_FULLNAME}.wic.p4.gz"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://sw-description.tmpl"
TEMPLATE_FILES += "sw-description.tmpl"

do_transform_template[vardeps] += "TARGET_IMAGE_UUID"
addtask do_transform_template before do_swupdate_binary after do_generate_image_uuid

TEMPLATE_VARS += "ROOTFS_PARTITION_NAME TARGET_IMAGE_UUID"

SWU_ADDITIONAL_FILES += "linux.efi ${ROOTFS_PARTITION_NAME}"
