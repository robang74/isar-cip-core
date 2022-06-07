#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT
#

inherit dpkg

DESCRIPTION = "Linux Test project for CIP"

SRC_URI = " \
   https://github.com/linux-test-project/ltp/releases/download/${PV}/ltp-full-${PV}.tar.xz \
   file://debian \
   "

do_prepare_build() {
        cp -R ${WORKDIR}/debian ${S}
        deb_create_compat
        deb_add_changelog
}
