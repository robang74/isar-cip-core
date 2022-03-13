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
SRC_URI = "file://control.tmpl"

DEBIAN_BUILD_DEPENDS = "ovmf"
TEMPLATE_FILES = "control.tmpl"
TEMPLATE_VARS += "PN DEBIAN_DEPENDS MAINTAINER DESCRIPTION DPKG_ARCH DEBIAN_BUILD_DEPENDS"

SSTATETASKS = ""

do_extract_ovmf() {
    install -m 0755 -d ${DEPLOY_DIR_IMAGE}
    cp -r ${BUILDCHROOT_DIR}/usr/share/OVMF ${DEPLOY_DIR_IMAGE}
    chown $(id -u):$(id -g) ${DEPLOY_DIR_IMAGE}/OVMF
}

addtask do_extract_ovmf after do_install_builddeps before do_dpkg_build
