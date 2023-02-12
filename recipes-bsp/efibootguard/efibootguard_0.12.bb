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
    "
SRC_URI[sha256sum] = "fd670f7a60a605c68ed411a9ab83ac680fbc9a9b5a8fd7b417c049f6cba5b6dc"

PROVIDES = "${PN}"
PROVIDES += "${PN}-dev"

DEPENDS = "python3-shtab"
BUILD_DEB_DEPENDS = "debhelper,autoconf-archive,check,gnu-efi,libpci-dev,pkg-config,python3-shtab,zlib1g-dev"
BUILD_DEB_DEPENDS:append:amd64 = ",libc6-dev-i386"
BUILD_DEB_DEPENDS:append:i386 = ",libc6-dev-i386"

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
