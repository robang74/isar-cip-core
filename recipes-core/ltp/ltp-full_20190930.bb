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

inherit dpkg

DESCRIPTION = "Linux Test project for CIP"

SRC_URI = " \
   https://github.com/linux-test-project/ltp/releases/download/20190930/ltp-full-${PV}.tar.xz \
   file://debian \
   "
SRC_URI[sha256sum] = "c7049590df2da3135030db5ef4c0076b76c789724a752b1102b4a01db0189f9a"


do_prepare_build() {
        cp -R ${WORKDIR}/debian ${S}
        deb_create_compat
        deb_add_changelog
}
