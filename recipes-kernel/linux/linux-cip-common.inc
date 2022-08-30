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
    https://git.kernel.org/pub/scm/linux/kernel/git/cip/linux-cip.git/snapshot/linux-cip-${PV}.tar.gz \
    "

SRC_URI_append = " ${@ "git://gitlab.com/cip-project/cip-kernel/cip-kernel-config.git;protocol=https;destsuffix=cip-kernel-config;name=cip-kernel-config" \
    if d.getVar('USE_CIP_KERNEL_CONFIG') == '1' else '' \
    }"

SRCREV_cip-kernel-config ?= "ce52837418aea714e780e0cbc8afb9515c12cc1b"

S = "${WORKDIR}/linux-cip-${PV}"
