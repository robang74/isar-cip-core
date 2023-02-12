#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#
# SPDX-License-Identifier: MIT
#

inherit dpkg-raw

PROVIDES += "secure-boot-secrets"

SB_KEY ??= ""
SB_CERT ??= ""

SRC_URI:append = " ${@ "file://"+d.getVar('SB_KEY') if d.getVar('SB_KEY') else '' }"
SRC_URI:append = " ${@ "file://"+d.getVar('SB_CERT') if d.getVar('SB_CERT') else '' }"

do_install() {
    if [ -z ${SB_KEY} ] || [ -z ${SB_CERT} ]; then
        bbfatal "You must set SB_KEY and SB_CERT and provide the required files as artifacts to this recipe"
    fi
    TARGET=${D}/usr/share/secure-boot-secrets
    install -d -m 0700 ${TARGET}
    install -m 0700 ${WORKDIR}/${SB_KEY} ${TARGET}/secure-boot.key
    install -m 0700 ${WORKDIR}/${SB_CERT} ${TARGET}/secure-boot.pem
}

do_prepare_build:append() {
    echo "Provides: secure-boot-secrets" >> ${S}/debian/control
}
