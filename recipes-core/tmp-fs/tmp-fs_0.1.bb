#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2021
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT

inherit dpkg-raw

SRC_URI = "file://postinst \
           file://tmp.mount.tmpl"

TMP_FS_SIZE ?= "500M"
TMP_FS_MODE ?= "755"
TMP_FS_OPTIONS = "nodev,nosuid,size=${TMP_SIZE},mode=${TMP_MODE}"

TEMPLATE_FILES = "tmp.mount.tmpl"
TEMPLATE_VARS += "TMP_FS_OPTIONS"

do_install[cleandirs]+="${D}/lib/systemd/system"
do_install() {
    install -m 0644 ${WORKDIR}/tmp.mount ${D}/lib/systemd/system/tmp.mount
}
