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
   https://github.com/linux-test-project/ltp/releases/download/${PV}/ltp-full-${PV}.tar.xz \
   file://debian \
   "
SRC_URI[sha256sum] = "d635afb5ec7b0de763ab50713baf9fbf65cf089da6e6768f816e4a166cbd17c4"


do_prepare_build() {
        cp -R ${WORKDIR}/debian ${S}
        deb_create_compat
        deb_add_changelog
}
