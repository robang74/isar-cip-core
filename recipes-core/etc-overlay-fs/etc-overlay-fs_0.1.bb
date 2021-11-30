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
           file://etc.mount \
           file://etc-hostname.service \
           file://etc-sshd-regen-keys.conf \
           file://etc-sysusers.conf"

do_install[cleandirs]+="${D}/usr/lib/systemd/system \
                        ${D}/usr/lib/systemd/system/local-fs.target.wants \
                        ${D}/usr/lib/systemd/system/systemd-sysusers.service.d \
                        ${D}/usr/lib/systemd/system/sshd-regen-keys.service.d \
                        ${D}/var/local/etc \
                        ${D}/var/local/.atomic \
                        "
do_install() {
    TARGET=${D}/usr/lib/systemd/system
    install -m 0644 ${WORKDIR}/etc.mount ${TARGET}/etc.mount
    install -m 0644 ${WORKDIR}/etc-hostname.service ${TARGET}/etc-hostname.service
    install -m 0644 ${WORKDIR}/etc-sshd-regen-keys.conf ${D}/usr/lib/systemd/system/sshd-regen-keys.service.d/etc-sshd-regen-keys.conf
    install -m 0644 ${WORKDIR}/etc-sysusers.conf ${D}/usr/lib/systemd/system/systemd-sysusers.service.d/etc-sysusers.service
}
