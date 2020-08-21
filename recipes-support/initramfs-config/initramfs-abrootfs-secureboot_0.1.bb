#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2020
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT

require recipes-support/initramfs-config/initramfs-config.inc

FILESPATH =. "${LAYERDIR_isar-siemens}/recipes-support/initramfs-config/files:"

DEBIAN_DEPENDS += ", busybox, patch"

SRC_URI += "file://postinst.ext \
            file://initramfs.lsblk.hook \
            file://initramfs.image_uuid.hook \
            file://secure-boot-debian-local-patch"

INITRAMFS_BUSYBOX = "y"

do_install() {
    # add patch for local to /usr/share/secure boot
    TARGET=${D}/usr/share/secureboot
    install -m 0755 -d ${TARGET}
    install -m 0644 ${WORKDIR}/secure-boot-debian-local-patch ${TARGET}/secure-boot-debian-local.patch
    # patch postinst
    sed -i -e '/configure)/r ${WORKDIR}/postinst.ext' ${WORKDIR}/postinst

    # add hooks for secure boot
    HOOKS=${D}/etc/initramfs-tools/hooks
    install -m 0755 -d ${HOOKS}
    install -m 0740 ${WORKDIR}/initramfs.lsblk.hook ${HOOKS}/lsblk.hook
    install -m 0740 ${WORKDIR}/initramfs.image_uuid.hook ${HOOKS}/image_uuid.hook
}
addtask do_install after do_transform_template
