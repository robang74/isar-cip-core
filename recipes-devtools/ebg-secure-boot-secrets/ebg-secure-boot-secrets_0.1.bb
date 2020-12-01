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

DESCRIPTION = "Add user defined secureboot certifcates to the buildchroot and the script to \
               sign an image with the given keys"

# variables
SB_CERT_PATH = "/usr/share/ebg-secure-boot"
SB_CERTDB ??= ""
SB_VERIFY_CERT ??= ""
SB_KEY_NAME ??= "demoDB"

# used to sign the image
DEBIAN_DEPENDS = "pesign, sbsigntool"

# this package cannot be install together with:
DEBIAN_CONFLICTS = "ebg-secure-boot-snakeoil"

SRC_URI = " \
    file://sign_secure_image.sh.tmpl \
    file://control.tmpl"
SRC_URI_append = " ${@ "file://"+d.getVar('SB_CERTDB') if d.getVar('SB_CERTDB') else '' }"
SRC_URI_append = " ${@ "file://"+d.getVar('SB_VERIFY_CERT') if d.getVar('SB_VERIFY_CERT') else '' }"
TEMPLATE_FILES = "sign_secure_image.sh.tmpl"
TEMPLATE_VARS += "SB_CERT_PATH SB_CERTDB SB_VERIFY_CERT SB_KEY_NAME"

TEMPLATE_FILES += "control.tmpl"
TEMPLATE_VARS += "PN MAINTAINER DPKG_ARCH DEBIAN_DEPENDS DESCRIPTION DEBIAN_CONFLICTS"

do_install() {
    TARGET=${D}${SB_CERT_PATH}
    install -m 0700 -d ${TARGET}
    cp -a ${WORKDIR}/${SB_CERTDB} ${TARGET}/${SB_CERTDB}
    chmod 700 ${TARGET}/${SB_CERTDB}
    install -m 0600 ${WORKDIR}/${SB_VERIFY_CERT} ${TARGET}/${SB_VERIFY_CERT}
    TARGET=${D}/usr/bin
    install -d ${TARGET}
    install -m 755 ${WORKDIR}/sign_secure_image.sh ${TARGET}/sign_secure_image.sh
}

addtask do_install after do_transform_template
