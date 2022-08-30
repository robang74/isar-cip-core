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

require recipes-bsp/u-boot/u-boot-common.inc

U_BOOT_BIN = "u-boot.bin"

do_deploy[dirs] = "${DEPLOY_DIR_IMAGE}"
do_deploy() {
    dpkg --fsys-tarfile "${WORKDIR}/u-boot-${MACHINE}_${PV}_${DISTRO_ARCH}.deb" | \
        tar xOf - "./usr/lib/u-boot/${MACHINE}/${U_BOOT_BIN}" \
        > "${DEPLOY_DIR_IMAGE}/firmware.bin"
}

addtask deploy after do_dpkg_build before do_deploy_deb
