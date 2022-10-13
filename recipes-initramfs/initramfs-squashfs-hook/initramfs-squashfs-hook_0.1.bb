#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Felix Moessbauer <felix.moessbauer@siemens.com>
#
# SPDX-License-Identifier: MIT
#

inherit dpkg-raw

SRC_URI += "file://squashfs.hook"

DEBIAN_DEPENDS = "initramfs-tools"

do_install[cleandirs] += " \
    ${D}/usr/share/initramfs-tools/hooks"

do_install() {
    install -m 0755 "${WORKDIR}/squashfs.hook" \
        "${D}/usr/share/initramfs-tools/hooks/squashfs"
}
