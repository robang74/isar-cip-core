#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2020-2022
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#  Jan Kiszka <jan.kiszka@siemens.com>
#
# SPDX-License-Identifier: MIT
#

inherit dpkg-raw

DESCRIPTION = "Signing script for EFI Boot Guard setups"

DEPENDS = "secure-boot-secrets"
DEBIAN_DEPENDS = "sbsigntool, secure-boot-secrets"

SRC_URI = "file://sign_secure_image.sh"

do_install() {
    TARGET=${D}/usr/bin
    install -d ${TARGET}
    install -m 755 ${WORKDIR}/sign_secure_image.sh ${TARGET}/sign_secure_image.sh
}
