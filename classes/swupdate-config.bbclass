#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2020
#
# Authors:
#  Christian Storm <christian.storm@siemens.com>
#
# SPDX-License-Identifier: MIT

# This class manages the config snippets together with their dependencies
# to build SWUpdate

inherit kconfig-snippets

BUILD_DEB_DEPENDS = " \
    zlib1g-dev, debhelper, libconfig-dev, libarchive-dev, \
    python-sphinx:native, dh-systemd, libsystemd-dev, libssl-dev, pkg-config"

SRC_URI += " ${@ 'git://gitlab.com/cip-project/cip-sw-updates/swupdate-handler-roundrobin.git;protocol=https;destsuffix=swupdate-handler-roundrobin;name=swupdate-handler-roundrobin;nobranch=1' \
    if d.getVar('SWUPDATE_USE_ROUND_ROBIN_HANDLER_REPO') == '1' else '' \
    }"
SRCREV_swupdate-handler-roundrobin ?= "6f561f136fdbe51d2e9066b934dfcb06b94c6624"

SWUPDATE_USE_ROUND_ROBIN_HANDLER_REPO ?= "1"
SWUPDATE_LUASCRIPT ?= "swupdate-handler-roundrobin/swupdate_handlers_roundrobin.lua"

KFEATURE_lua = ""
KFEATURE_lua[BUILD_DEB_DEPENDS] = "liblua5.3-dev"
KFEATURE_lua[KCONFIG_SNIPPETS] = "file://swupdate_defconfig_lua.snippet"

KFEATURE_luahandler = ""
KFEATURE_luahandler[KCONFIG_SNIPPETS] = "file://swupdate_defconfig_luahandler.snippet"
KFEATURE_luahandler[SRC_URI] = "${@ 'file://${SWUPDATE_LUASCRIPT}' \
                                  if d.getVar('SWUPDATE_USE_ROUND_ROBIN_HANDLER_REPO') == '0' else '' }"
KFEATURE_DEPS = ""
KFEATURE_DEPS[luahandler] = "lua"

KFEATURE_efibootguard = ""
KFEATURE_efibootguard[BUILD_DEB_DEPENDS] = "efibootguard-dev"
KFEATURE_efibootguard[DEBIAN_DEPENDS] = "efibootguard-dev"
KFEATURE_efibootguard[DEPENDS] = "efibootguard-dev"
KFEATURE_efibootguard[KCONFIG_SNIPPETS] = "file://swupdate_defconfig_efibootguard.snippet"

KFEATURE_mtd = ""
KFEATURE_mtd[BUILD_DEB_DEPENDS] = "libmtd-dev"
KFEATURE_mtd[DEPENDS] = "mtd-utils"
KFEATURE_mtd[KCONFIG_SNIPPETS] = "file://swupdate_defconfig_mtd.snippet"

KFEATURE_ubi = ""
KFEATURE_ubi[BUILD_DEB_DEPENDS] = "libubi-dev"
KFEATURE_ubi[KCONFIG_SNIPPETS] = "file://swupdate_defconfig_ubi.snippet"

KFEATURE_DEPS[ubi] = "mtd"

KFEATURE_u-boot = ""
KFEATURE_u-boot[BUILD_DEB_DEPENDS] = "libubootenv-dev"
# we need u-boot-${MACHINE}-config for fw_env.config
# only custom build u-boot provides this package
# for u-boot provided by debian u-boot-tools provides
# example configurations at /usr/share/doc/u-boot-tools/examples
KFEATURE_u-boot[DEBIAN_DEPENDS] = "${@ 'libubootenv0.1, u-boot-${MACHINE}-config' \
                                          if d.getVar("U_BOOT_CONFIG_PACKAGE", True) == "1" \
                                          else 'libubootenv0.1'}"
KFEATURE_u-boot[DEPENDS] = "${@ 'libubootenv u-boot-${MACHINE}-config' \
                                          if d.getVar("U_BOOT_CONFIG_PACKAGE", True) == "1" \
                                          else 'libubootenv'}"
KFEATURE_u-boot[KCONFIG_SNIPPETS] = "file://swupdate_defconfig_u-boot.snippet"

def get_bootloader_featureset(d):
    bootloader = d.getVar("SWUPDATE_BOOTLOADER", True) or ""
    if bootloader == "efibootguard":
        return "efibootguard"
    if bootloader == "u-boot":
        return "u-boot"
    return ""

SWUPDATE_KFEATURES ??= ""
KFEATURES = "${SWUPDATE_KFEATURES}"
KFEATURES += "${@get_bootloader_featureset(d)}"

# Astonishingly, as an anonymous python function, SWUPDATE_BOOTLOADER is always None
# one time before it gets set. So the following must be a task.
python do_check_bootloader () {
    bootloader = d.getVar("SWUPDATE_BOOTLOADER", True) or "None"
    if not bootloader in ["efibootguard", "u-boot"]:
        bb.warn("swupdate: SWUPDATE_BOOTLOADER set to incompatible value: " + bootloader)
}
addtask check_bootloader before do_fetch
