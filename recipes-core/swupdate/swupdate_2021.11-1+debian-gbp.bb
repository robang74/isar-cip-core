#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2021
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT

inherit dpkg-gbp

require swupdate.inc

DEB_BUILD_PROFILES += "nodoc"
DEB_BUILD_OPTIONS += "nodoc"

SRC_URI = "git://salsa.debian.org/debian/swupdate.git;protocol=https;branch=debian/master"
SRCREV ="344548c816b555c58ec199f31e45703897d23fb5"

# add options to DEB_BUILD_PROFILES
SRC_URI += "file://0001-debian-Remove-SWUpdate-USB-service-and-Udev-rules.patch \
            file://0002-debian-rules-Add-Embedded-Lua-handler-option.patch \
            file://0003-debian-rules-Add-option-to-disable-fs-creation.patch \
            file://0004-debian-rules-Add-option-to-disable-webserver.patch \
            file://0005-debian-Add-patch-to-fix-bootloader_env_get-for-EBG.patch"

# end patching for dm-verity based images

# deactivate signing and hardware compability for simple a/b rootfs update
DEB_BUILD_PROFILES += "pkg.swupdate.nosigning"
DEB_BUILD_PROFILES += "pkg.swupdate.nohwcompat"

# add cross build and deactivate testing for arm based builds
DEB_BUILD_PROFILES += "cross nocheck"
# If the luahandler shall be embedded into the swupdate binary
# include the following lines.
# DEPENDS += "swupdate-handlers"
# GBP_DEPENDS += "swupdate-handlers"
# DEB_BUILD_PROFILES += "pkg.swupdate.embeddedlua"

# modify for debian buster build
SRC_URI_append_buster = " file://0006-debian-prepare-build-for-isar-debian-buster.patch"

# disable create filesystem due to missing symbols in debian buster
# disable webserver due to missing symbols in debian buster
DEB_BUILD_PROFILES_append_buster = " \
                                   pkg.swupdate.bpo \
                                   pkg.swupdate.nocreatefs \
                                   pkg.swupdate.nowebserver "
# In debian buster the git-compression defaults to gz and does not detect other
# compression formats.
GBP_EXTRA_OPTIONS += "--git-compression=xz"
