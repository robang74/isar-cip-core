#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2019
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT
#

inherit wic-img
inherit targz-img

addtask do_targz_image after do_wic_image
