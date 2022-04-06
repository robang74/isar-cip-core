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
            file://debian-local-patch"

do_install() {
    # add patch for local to /usr/share/initramfs-abrootfs-hook
    TARGET=${D}/usr/share/initramfs-abrootfs-hook
    install -m 0755 -d ${TARGET}
    install -m 0644 ${WORKDIR}/debian-local-patch ${TARGET}/debian-local.patch

    # add hooks for secure boot
    HOOKS=${D}/etc/initramfs-tools/hooks
    install -m 0755 -d ${HOOKS}
    install -m 0740 ${WORKDIR}/initramfs.lsblk.hook ${HOOKS}/lsblk.hook
    install -m 0740 ${WORKDIR}/initramfs.image_uuid.hook ${HOOKS}/image_uuid.hook
}
addtask do_install after do_transform_template
