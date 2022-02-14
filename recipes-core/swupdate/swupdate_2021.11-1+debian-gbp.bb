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

include swupdate.inc

SRC_URI = "git://salsa.debian.org/debian/swupdate.git;protocol=https;branch=debian/master"
SRCREV ="debian/2021.11-1"

# add options to DEB_BUILD_PROFILES
SRC_URI += "file://0001-debian-config-Make-image-encryption-optional.patch \
            file://0002-debian-rules-Add-CONFIG_MTD.patch \
            file://0003-debian-rules-Add-option-to-disable-fs-creation.patch \
            file://0004-debian-rules-Add-option-to-disable-webserver.patch \
            file://0005-debian-Make-CONFIG_HW_COMPATIBILTY-optional.patch \
            file://0006-debian-rules-Add-Embedded-Lua-handler-option.patch \
            file://0007-debian-Remove-SWUpdate-USB-service-and-Udev-rules.patch \
            file://0008-Add-Profile-option-to-disable-CONFIG_HASH_VERIFY.patch"

# end patching for dm-verity based images

# deactivate signing and encryption for simple a/b rootfs update
SWUPDATE_BUILD_PROFILES += "pkg.swupdate.nosigning pkg.swupdate.noencryption"

# add cross build and deactivate testing for arm based builds
SWUPDATE_BUILD_PROFILES += "cross nocheck"
# If the luahandler shall be embedded into the swupdate binary
# include the following lines.
# DEPENDS += "swupdate-handlers"
# GBP_DEPENDS += "swupdate-handlers"
# SWUPDATE_BUILD_PROFILES += "pkg.swupdate.embeddedlua"

# modify for debian buster build
SRC_URI_append_buster = " file://0009-debian-prepare-build-for-isar-debian-buster.patch"

# disable documentation due to missing packages
SWUPDATE_BUILD_PROFILES_append = " nodoc "

# disable create filesystem due to missing symbols in debian buster
# disable webserver due to missing symbols in debian buster
SWUPDATE_BUILD_PROFILES_append_buster = " \
                                   pkg.swupdate.nocreatefs \
                                   pkg.swupdate.nowebserver "
# In debian buster the git-compression defaults to gz and does not detect other
# compression formats.
GBP_EXTRA_OPTIONS += "--git-compression=xz"
