#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2021-2022
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT

DESCRIPTION = "swupdate utility for software updates"
HOMEPAGE= "https://github.com/sbabic/swupdate"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${LAYERDIR_isar}/licenses/COPYING.GPLv2;md5=751419260aa954499f7abaabaa882bbe"

def get_bootloader_build_profile(d):
    bootloader = d.getVar("SWUPDATE_BOOTLOADER") or ""
    if bootloader == "efibootguard":
        return "pkg.swupdate.efibootguard"
    if bootloader == "u-boot":
        return "pkg.swupdate.uboot"
    return ""

DEB_BUILD_PROFILES += "${@get_bootloader_build_profile(d)}"

def get_bootloader_dependencies(d):
    bootloader = d.getVar("SWUPDATE_BOOTLOADER") or ""
    if bootloader == "efibootguard":
        return "efibootguard-dev"
    if bootloader == "u-boot":
        if d.getVar("U_BOOT_CONFIG_PACKAGE") == "1":
            return "libubootenv u-boot-{}-config".format(d.getVar("MACHINE"))
        else:
            return "libubootenv"
    return ""

DEPENDS += "${@get_bootloader_dependencies(d)}"
DEPENDS += "${@bb.utils.contains('DEB_BUILD_PROFILES', 'mtd', 'mtd-utils', '', d)}"

python do_check_bootloader () {
    bootloader = d.getVar("SWUPDATE_BOOTLOADER") or "None"
    if not bootloader in ["efibootguard", "u-boot"]:
        bb.warn("swupdate: SWUPDATE_BOOTLOADER set to incompatible value: " + bootloader)
}
addtask check_bootloader before do_fetch
