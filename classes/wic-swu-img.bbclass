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


inherit wic-img
inherit extract-partition
inherit swupdate-img

SOURCE_IMAGE_FILE = "${WIC_IMAGE_FILE}"

addtask do_extract_partition after do_wic_image
addtask do_swupdate_image after do_extract_partition
