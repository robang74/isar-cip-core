#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2021
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

SWUPDATE_BUILD_PROFILES += "${@get_bootloader_build_profile(d)}"

def get_bootloader_dependencies(d):
    bootloader = d.getVar("SWUPDATE_BOOTLOADER", True) or ""
    if bootloader == "efibootguard":
        return "efibootguard-dev"
    if bootloader == "u-boot":
        if d.getVar("U_BOOT_CONFIG_PACKAGE", True) == "1":
            return "libubootenv u-boot-{}-config".format(d.getVar("MACHINE", TRUE))
        else:
            return "libubootenv"
    return ""

DEPENDS += "${@get_bootloader_dependencies(d)}"
DEPENDS += "${@bb.utils.contains('SWUPDATE_BUILD_PROFILES', 'mtd', 'mtd-utils', '', d)}"

do_install_builddeps_prepend() {
    export DEB_BUILD_PROFILES="${SWUPDATE_BUILD_PROFILES}"
}

dpkg_runbuild_prepend() {
    export DEB_BUILD_PROFILES="${SWUPDATE_BUILD_PROFILES}"
}

python do_check_bootloader () {
    bootloader = d.getVar("SWUPDATE_BOOTLOADER", True) or "None"
    if not bootloader in ["efibootguard", "u-boot"]:
        bb.warn("swupdate: SWUPDATE_BOOTLOADER set to incompatible value: " + bootloader)
}
addtask check_bootloader before do_fetch
