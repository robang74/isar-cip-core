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
    https://gitlab.com/cip-project/cip-kernel/linux-cip/-/archive/v${PV}/linux-cip-v${PV}.tar.gz \
    "

SRC_URI_append = " ${@conditional("USE_CIP_KERNEL_CONFIG", "1", \
    "git://gitlab.com/cip-project/cip-kernel/cip-kernel-config.git;protocol=https;destsuffix=cip-kernel-config;name=cip-kernel-config", \
    "file://${KERNEL_DEFCONFIG}",d)}"
SRCREV_cip-kernel-config ?= "7f2930b9667372f94f2edb42ca9cf6fc6c0aed50"

S = "${WORKDIR}/linux-cip-v${PV}"
