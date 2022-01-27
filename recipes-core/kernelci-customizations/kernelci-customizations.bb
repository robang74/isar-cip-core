#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2019
# Copyright (c) Cybertrust Japan Co., Ltd., 2021
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#  Alice Ferrazzi <alice.ferrazzi@miraclelinux.com>
#
# SPDX-License-Identifier: MIT
#

require recipes-core/customizations/common.inc

DESCRIPTION = "CIP Core KernelCI image customizations"

SRC_URI += "file://dmesg.sh"

do_install_append() {
  install -v -d ${D}/opt/kernelci
  install -v -m 744 ${WORKDIR}/dmesg.sh ${D}/opt/kernelci/
}
