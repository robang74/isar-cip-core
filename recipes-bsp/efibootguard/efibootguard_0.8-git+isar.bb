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

SRCREV = "ac1685aea75fb3e3d16c0c0e4f8261a2edb63536"

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

dpkg_runbuild_append() {
    install -m 0755 -d ${DEPLOY_DIR_IMAGE}
    install -m 0755 ${S}/efibootguardx64.efi ${DEPLOY_DIR_IMAGE}/bootx64.efi
    install -m 0755 ${S}/bg_setenv ${DEPLOY_DIR_IMAGE}/bg_setenv
}
