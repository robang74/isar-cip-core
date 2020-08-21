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

DESCRIPTION = "Add script to sign for secure boot with the debian snakeoil keys"
# used to sign the image
DEBIAN_DEPENDS = "pesign,  sbsigntool, ovmf, openssl, libnss3-tools"


# this package cannot be install together with:
DEBIAN_CONFLICTS = "ebg-secure-boot-secrets"

SRC_URI = "file://sign_secure_image.sh \
           file://control.tmpl"

TEMPLATE_FILES = "control.tmpl"
TEMPLATE_VARS += "PN MAINTAINER DPKG_ARCH DEBIAN_DEPENDS DESCRIPTION DEBIAN_CONFLICTS"

do_install() {
    TARGET=${D}/usr/bin
    install -d ${TARGET}
    install -m 755 ${WORKDIR}/sign_secure_image.sh ${TARGET}/sign_secure_image.sh
}

addtask do_install after do_transform_template
