#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2019-2022
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#
# SPDX-License-Identifier: MIT
#

require common.inc

DESCRIPTION = "CIP Core image demo & customizations"

do_prepare_build:prepend_qemu-riscv64() {
	if ! grep -q serial-getty@hvc0.service ${WORKDIR}/postinst; then
		# suppress SBI console - overlaps with serial console
		echo >> ${WORKDIR}/postinst
		echo "systemctl mask serial-getty@hvc0.service" >> ${WORKDIR}/postinst
	fi
}
