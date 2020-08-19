#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2019
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#
# SPDX-License-Identifier: MIT
#

inherit dpkg-raw

DESCRIPTION = "CIP Core image demo & customizations"

SRC_URI = " \
    file://postinst \
    file://ethernet \
    file://99-silent-printk.conf"

DEPENDS += "sshd-regen-keys"

DEBIAN_DEPENDS = " \
    ifupdown, isc-dhcp-client, net-tools, iputils-ping, ssh, sshd-regen-keys"

do_install() {
	install -v -d ${D}/etc/network/interfaces.d
	install -v -m 644 ${WORKDIR}/ethernet ${D}/etc/network/interfaces.d/

	install -v -d ${D}/etc/sysctl.d
	install -v -m 644 ${WORKDIR}/99-silent-printk.conf ${D}/etc/sysctl.d/
}
