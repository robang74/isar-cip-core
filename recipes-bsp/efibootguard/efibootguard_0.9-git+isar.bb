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

SRC_URI = "git://github.com/siemens/efibootguard.git;branch=master;protocol=https \
           file://debian \
          "

S = "${WORKDIR}/git"

SRCREV = "c01324d0da202727eb0744c0f67a78f9c9b65c46"

PROVIDES = "${PN}"
PROVIDES += "${PN}-dev"

BUILD_DEB_DEPENDS = "gnu-efi,libpci-dev,check,pkg-config,libc6-dev-i386"

inherit dpkg

TEMPLATE_FILES = "debian/control.tmpl"
TEMPLATE_VARS += "DESCRIPTION_DEV BUILD_DEB_DEPENDS"

do_prepare_build() {
    cp -R ${WORKDIR}/debian ${S}
    deb_add_changelog
}

