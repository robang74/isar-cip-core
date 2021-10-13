#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2020
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT

DESCRIPTION = "swupdate utility for software updates"
HOMEPAGE= "https://github.com/sbabic/swupdate"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${LAYERDIR_isar}/licenses/COPYING.GPLv2;md5=751419260aa954499f7abaabaa882bbe"

SRC_URI = "git://github.com/sbabic/swupdate.git;branch=master;protocol=https"

SRCREV = "47a1246435fdb78fba15cc969596994130412956"
PV = "2021.4-git+isar"

DEFCONFIG := "swupdate_defconfig"

SRC_URI += "file://debian \
            file://${DEFCONFIG} \
            file://${PN}.cfg"

DEBIAN_DEPENDS = "${shlibs:Depends}, ${misc:Depends}"

inherit dpkg
inherit swupdate-config

KFEATURES += "luahandler"

S = "${WORKDIR}/git"

TEMPLATE_FILES = "debian/changelog.tmpl debian/control.tmpl debian/rules.tmpl"
TEMPLATE_VARS += "BUILD_DEB_DEPENDS DEFCONFIG DEBIAN_DEPENDS"

do_prepare_build() {
    cp -R ${WORKDIR}/debian ${S}

    install -m 0644 ${WORKDIR}/${PN}.cfg ${S}/swupdate.cfg
    install -m 0644 ${WORKDIR}/${DEFCONFIG}.gen ${S}/configs/${DEFCONFIG}

    if ! grep -q "configs/${DEFCONFIG}" ${S}/.gitignore; then
        echo "configs/${DEFCONFIG}" >> ${S}/.gitignore
    fi
}
