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

require recipes-bsp/u-boot/u-boot-custom.inc

SRC_URI += " \
    https://ftp.denx.de/pub/u-boot/u-boot-${PV}.tar.bz2 \
    file://0001-lib-date-Make-rtc_mktime-and-mktime64-Y2038-ready.patch \
    file://rules.tmpl;subdir=debian"
SRC_URI[sha256sum] = "68e065413926778e276ec3abd28bb32fa82abaa4a6898d570c1f48fbdb08bcd0"

SRC_URI_append_secureboot = " \
    file://secure-boot.cfg"

S = "${WORKDIR}/u-boot-${PV}"

DEBIAN_BUILD_DEPENDS += ", libssl-dev:native, libssl-dev:arm64"

DEBIAN_BUILD_DEPENDS_append_secureboot = ", \
    openssl, pesign, secure-boot-secrets, python3-openssl:native"
DEPENDS_append_secureboot = " secure-boot-secrets"

U_BOOT_CONFIG = "qemu_arm64_defconfig"
U_BOOT_BIN = "u-boot.bin"

do_prepare_build_append_secureboot() {
    sed -ni '/### Secure boot config/q;p' ${S}/configs/${U_BOOT_CONFIG}
    cat ${WORKDIR}/secure-boot.cfg >> ${S}/configs/${U_BOOT_CONFIG}
}

do_deploy[dirs] = "${DEPLOY_DIR_IMAGE}"
do_deploy() {
    dpkg --fsys-tarfile "${WORKDIR}/u-boot-${MACHINE}_${PV}_${DISTRO_ARCH}.deb" | \
        tar xOf - "./usr/lib/u-boot/${MACHINE}/${U_BOOT_BIN}" \
        > "${DEPLOY_DIR_IMAGE}/firmware.bin"
}

addtask deploy after do_dpkg_build before do_deploy_deb
