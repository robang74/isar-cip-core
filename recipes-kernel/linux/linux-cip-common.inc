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

KERNEL_DEFCONFIG ?= "${MACHINE}_defconfig"

def conditional(variable, checkvalue, truevalue, falsevalue, d):
    if d.getVar(variable) == checkvalue:
        return truevalue
    else:
        return falsevalue

require recipes-kernel/linux/linux-custom.inc

SRC_URI += " \
    https://git.kernel.org/pub/scm/linux/kernel/git/cip/linux-cip.git/snapshot/linux-cip-${PV}.tar.gz \
    "

SRC_URI_append = " ${@conditional("USE_CIP_KERNEL_CONFIG", "1", \
    "git://gitlab.com/cip-project/cip-kernel/cip-kernel-config.git;protocol=https;destsuffix=cip-kernel-config;name=cip-kernel-config", \
    "file://${KERNEL_DEFCONFIG}",d)}"
SRCREV_cip-kernel-config ?= "f88ee1e75253104f975263cf4d0bddd557388197"
