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

inherit dpkg-raw

DESCRIPTION = "Copy the OVMF biniaries from the build changeroot to the deploy dir"

# this is a empty debian package
SRC_URI = "file://rules"

DEBIAN_BUILD_DEPENDS = "ovmf"

SSTATETASKS = ""

do_install() {
     install -v -d ${D}/var/share
     touch ${D}/var/share/test
}

do_deploy() {
    install -m 0755 -d ${DEPLOY_DIR_IMAGE}
    dpkg --extract ${WORKDIR}/${PN}_${PV}*.deb ${WORKDIR}
    cp -r ${WORKDIR}/var/share/OVMF ${DEPLOY_DIR_IMAGE}
}
addtask do_deploy after do_dpkg_build before do_deploy_deb


