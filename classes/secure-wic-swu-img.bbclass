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

inherit verity-img
inherit wic-swu-img

addtask do_wic_image after do_verity_image
