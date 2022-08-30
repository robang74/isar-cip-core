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

require u-boot-common.inc

U_BOOT_CONFIG = "am335x_evm_defconfig"
U_BOOT_BIN = "all"

EFI_ARCH = "arm"

do_prepare_build_append() {
    echo "MLO u-boot.img /usr/lib/u-boot/${MACHINE}" > \
        ${S}/debian/u-boot-${MACHINE}.install
}
