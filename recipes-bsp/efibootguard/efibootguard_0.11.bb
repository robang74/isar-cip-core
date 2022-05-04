#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2020
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT
#

DESCRIPTION = "efibootguard boot loader"
DESCRIPTION_DEV = "efibootguard development library"
HOMEPAGE = "https://github.com/siemens/efibootguard"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${LAYERDIR_isar}/licenses/COPYING.GPLv2;md5=751419260aa954499f7abaabaa882bbe"
MAINTAINER = "Jan Kiszka <jan.kiszka@siemens.com>"

SRC_URI = " \
    https://github.com/siemens/efibootguard/archive/refs/tags/v${PV}.tar.gz;downloadfilename=efitbootguard-v${PV}.tar.gz \
    file://debian \
    file://0001-Makefile-Drop-nostdinc-for-EFI-binaries.patch \
    "
SRC_URI[sha256sum] = "12bd84ff63a34bef56e489b48d4f97955aa4d864eeff9ea2dea1d24a286d8ebe"

PROVIDES = "${PN}"
PROVIDES += "${PN}-dev"

DEPENDS = "python3-shtab"
BUILD_DEB_DEPENDS = "dh-exec,gnu-efi,libpci-dev,check,pkg-config,python3-shtab"
BUILD_DEB_DEPENDS_append_amd64 = ",libc6-dev-i386"
BUILD_DEB_DEPENDS_append_i386 = ",libc6-dev-i386"

inherit dpkg

# needed for buster, bullseye could use compat >= 13
python() {
    arch = d.getVar('DISTRO_ARCH')
    cmd = 'dpkg-architecture -a {} -q DEB_HOST_MULTIARCH'.format(arch)
    with os.popen(cmd) as proc:
        d.setVar('DEB_HOST_MULTIARCH', proc.read())
}

TEMPLATE_FILES = "debian/control.tmpl debian/efibootguard-dev.install.tmpl"
TEMPLATE_VARS += "DESCRIPTION_DEV BUILD_DEB_DEPENDS DEB_HOST_MULTIARCH"

do_prepare_build() {
    cp -R ${WORKDIR}/debian ${S}
    deb_add_changelog
}
