#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2020
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT


inherit dpkg-raw

DEBIAN_DEPENDS += ", busybox, patch"

SRC_URI += "file://postinst \
            file://initramfs.lsblk.hook \
            file://initramfs.image_uuid.hook \
            file://secure-boot-debian-local-patch"

do_install() {
    # add patch for local to /usr/share/secure boot
    TARGET=${D}/usr/share/secureboot
    install -m 0755 -d ${TARGET}
    install -m 0644 ${WORKDIR}/secure-boot-debian-local-patch ${TARGET}/secure-boot-debian-local.patch

    # add hooks for secure boot
    HOOKS=${D}/etc/initramfs-tools/hooks
    install -m 0755 -d ${HOOKS}
    install -m 0740 ${WORKDIR}/initramfs.lsblk.hook ${HOOKS}/lsblk.hook
    install -m 0740 ${WORKDIR}/initramfs.image_uuid.hook ${HOOKS}/image_uuid.hook
}
addtask do_install after do_transform_template
