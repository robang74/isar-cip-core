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

require linux-cip-common.inc

SRC_URI += " \
    https://git.kernel.org/pub/scm/linux/kernel/git/cip/linux-cip.git/snapshot/linux-cip-${PV}.tar.gz \
    file://preempt-rt.cfg"

SRC_URI[sha256sum] = "7280f3611ed329996f27583321bed92b3791a047f42a94c75c7e921200b2862d"

S = "${WORKDIR}/linux-cip-${PV}"

do_prepare_build_prepend() {
    cat ${WORKDIR}/preempt-rt.cfg >> ${WORKDIR}/${KERNEL_DEFCONFIG}
}
