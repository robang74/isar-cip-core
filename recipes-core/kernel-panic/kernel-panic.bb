#
# CIP Core, generic profile
#
# Copyright (c) Toshiba Corporation, 2022
#
# Authors:
#  Shivanand Kunijadar <Shivanand.Kunijadar@toshiba-tsip.com>
#
# SPDX-License-Identifier: MIT
#

inherit dpkg-raw

DESCRIPTION = "Systemd service file to cause kernel panic"

SRC_URI = " \
    file://sysrq-panic.service"

do_install() {
	install -v -d ${D}/lib/systemd/system
	install -v -m 0644 ${WORKDIR}/sysrq-panic.service ${D}/lib/systemd/system/
	install -v -d ${D}/etc/systemd/system/default.target.wants
	ln -s /lib/systemd/system/sysrq-panic.service ${D}/etc/systemd/system/default.target.wants/
}
