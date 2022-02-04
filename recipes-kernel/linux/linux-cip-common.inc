#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#
# SPDX-License-Identifier: MIT
#

FILESEXTRAPATHS_prepend := "${FILE_DIRNAME}/files:"

KERNEL_DEFCONFIG ?= "${MACHINE}_defconfig"

require recipes-kernel/linux/linux-custom.inc

SRC_URI += " \
    https://gitlab.com/cip-project/cip-kernel/linux-cip/-/archive/v${PV}/linux-cip-v${PV}.tar.gz \
    "

SRC_URI_append = " ${@ "git://gitlab.com/cip-project/cip-kernel/cip-kernel-config.git;protocol=https;destsuffix=cip-kernel-config;name=cip-kernel-config" \
    if d.getVar('USE_CIP_KERNEL_CONFIG') == '1' else '' \
    }"

SRC_URI_append_bbb = "file://${KERNEL_DEFCONFIG}"

SRCREV_cip-kernel-config ?= "3f527304fdadd163e20b7a5a9cfabaca7506c716"

S = "${WORKDIR}/linux-cip-v${PV}"
