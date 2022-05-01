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

SRC_URI += " \
    file://etc-overlay.hook \
    file://etc-overlay.script \
    "

DEBIAN_DEPENDS = "initramfs-tools"

do_install[cleandirs] += " \
    ${D}/usr/share/initramfs-tools/hooks \
    ${D}/usr/share/initramfs-tools/scripts/local-bottom"

do_install() {
    install -m 0755 "${WORKDIR}/etc-overlay.hook" \
        "${D}/usr/share/initramfs-tools/hooks/etc-overlay"
    install -m 0755 "${WORKDIR}/etc-overlay.script" \
        "${D}/usr/share/initramfs-tools/scripts/local-bottom/etc-overlay"
}
