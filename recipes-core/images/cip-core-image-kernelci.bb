#
# A reference image for KernelCI
#
# Copyright (c) Cybertrust Japan Co., Ltd., 2021
#
# Authors:
#  Alice Ferrazzi <alice.ferrazzi@miraclelinux.com>
#
# SPDX-License-Identifier: MIT
#

inherit image

DESCRIPTION = "CIP Core image for KernelCI"

IMAGE_INSTALL += "kernelci-customizations"
