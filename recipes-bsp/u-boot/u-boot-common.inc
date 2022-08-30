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
    file://rules.tmpl;subdir=debian"
SRC_URI[sha256sum] = "92b08eb49c24da14c1adbf70a71ae8f37cc53eeb4230e859ad8b6733d13dcf5e"

SRC_URI_append_secureboot = " \
    file://secure-boot.cfg.tmpl"

S = "${WORKDIR}/u-boot-${PV}"

DEBIAN_BUILD_DEPENDS += ", libssl-dev:native, libssl-dev:${DISTRO_ARCH}"

DEBIAN_BUILD_DEPENDS_append_secureboot = ", \
    openssl, pesign, secure-boot-secrets, python3-openssl:native"
DEPENDS_append_secureboot = " secure-boot-secrets"

TEMPLATE_FILES_append_secureboot = " secure-boot.cfg.tmpl"
TEMPLATE_VARS_append_secureboot = " EFI_ARCH"

do_prepare_build_append_secureboot() {
    sed -ni '/### Secure boot config/q;p' ${S}/configs/${U_BOOT_CONFIG}
    cat ${WORKDIR}/secure-boot.cfg >> ${S}/configs/${U_BOOT_CONFIG}
}
