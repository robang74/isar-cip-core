# ex:ts=4:sw=4:sts=4:et
# -*- tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-
#
# Copyright (c) 2014, Intel Corporation.
# Copyright (c) 2018, Siemens AG.
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# DESCRIPTION
# This implements the 'efibootguard-boot' source plugin class for 'wic'
#
# AUTHORS
# Tom Zanussi <tom.zanussi (at] linux.intel.com>
# Claudius Heine <ch (at] denx.de>
# Andreas Reichel <andreas.reichel.ext (at] siemens.com>
# Christian Storm <christian.storm (at] siemens.com>

import os
import fnmatch
import sys
import logging

msger = logging.getLogger('wic')

from wic.pluginbase import SourcePlugin
from wic.utils.misc import exec_cmd, get_bitbake_var, BOOTDD_EXTRA_SPACE

class EfibootguardBootPlugin(SourcePlugin):
    """
    Create EFI Boot Guard partition hosting the
    environment file plus Kernel files.
    """

    name = 'efibootguard-boot'

    @classmethod
    def do_prepare_partition(cls, part, source_params, creator, cr_workdir,
                             oe_builddir, deploy_dir, kernel_dir,
                             rootfs_dir, native_sysroot):
        """
        Called to do the actual content population for a partition, i.e.,
        populate an EFI Boot Guard environment partition plus Kernel files.
        """

        kernel_image = get_bitbake_var("KERNEL_IMAGE")
        if not kernel_image:
            msger.warning("KERNEL_IMAGE not set. Use default:")
            kernel_image = "vmlinuz"
        boot_image = kernel_image

        initrd_image = get_bitbake_var("INITRD_IMAGE")
        if not initrd_image:
            msger.warning("INITRD_IMAGE not set\n")
            initrd_image = "initrd.img"
        bootloader = creator.ks.bootloader

        deploy_dir = get_bitbake_var("DEPLOY_DIR_IMAGE")
        if not deploy_dir:
            msger.error("DEPLOY_DIR_IMAGE not set, exiting\n")
            sys.exit(1)
        creator.deploy_dir = deploy_dir

        wdog_timeout = get_bitbake_var("WDOG_TIMEOUT")
        if not wdog_timeout:
            msger.error("Specify watchdog timeout for \
            efibootguard in local.conf with WDOG_TIMEOUT=")
            exit(1)


        boot_files = source_params.get("files", "").split(' ')
        cmdline = bootloader.append
        root_dev = source_params.get("root", None)
        if not root_dev:
            msger.error("Specify root in source params")
            exit(1)
            root_dev = root_dev.replace(":", "=")

        cmdline += " root=%s rw" % root_dev
        boot_files.append(kernel_image)
        boot_files.append(initrd_image)
        cmdline += "initrd=%s" % initrd_image if initrd_image else ""

        part_rootfs_dir = "%s/disk/%s.%s" % (cr_workdir,
                                             part.label, part.lineno)
        create_dir_cmd = "install -d %s" % part_rootfs_dir
        exec_cmd(create_dir_cmd)

        cwd = os.getcwd()
        os.chdir(part_rootfs_dir)
        config_cmd = '%s/bg_setenv -f . -k "C:%s:%s" %s -r %s -w %s' \
            % (
                deploy_dir,
                part.label.upper(),
                boot_image,
                '-a "%s"' % cmdline if cmdline else "",
                source_params.get("revision", 1),
                wdog_timeout
            )
        exec_cmd(config_cmd, True)
        os.chdir(cwd)

        boot_files = list(filter(None, boot_files))
        for boot_file in boot_files:
            if os.path.isfile("%s/%s" % (kernel_dir, kernel_image)):
                install_cmd = "install -m 0644 %s/%s %s/%s" % \
                    (kernel_dir, boot_file, part_rootfs_dir, boot_file)
                exec_cmd(install_cmd)
            else:
                msger.error("file %s not found in directory %s",
                            boot_file, kernel_dir)
                exit(1)
        cls._create_img(part_rootfs_dir, part, cr_workdir)

    @classmethod
    def _create_img(cls, part_rootfs_dir, part, cr_workdir):
            # Write label as utf-16le to EFILABEL file
        with open("%s/EFILABEL" % part_rootfs_dir, 'wb') as filedescriptor:
            filedescriptor.write(part.label.upper().encode("utf-16le"))

        du_cmd = "du --apparent-size -ks %s" % part_rootfs_dir
        blocks = int(exec_cmd(du_cmd).split()[0])

        extra_blocks = part.get_extra_block_count(blocks)
        if extra_blocks < BOOTDD_EXTRA_SPACE:
            extra_blocks = BOOTDD_EXTRA_SPACE

        blocks += extra_blocks
        blocks = blocks + (16 - (blocks % 16))

        msger.debug("Added %d extra blocks to %s to get to %d total blocks",
                    extra_blocks, part.mountpoint, blocks)

        # dosfs image, created by mkdosfs
        bootimg = "%s/%s.%s.img" % (cr_workdir, part.label, part.lineno)

        dosfs_cmd = "mkdosfs -F 16 -S 512 -n %s -C %s %d" % \
            (part.label.upper(), bootimg, blocks)
        exec_cmd(dosfs_cmd)

        mcopy_cmd = "mcopy -v -i %s -s %s/* ::/" % (bootimg, part_rootfs_dir)
        exec_cmd(mcopy_cmd, True)

        chmod_cmd = "chmod 644 %s" % bootimg
        exec_cmd(chmod_cmd)

        du_cmd = "du -Lbks %s" % bootimg
        bootimg_size = int(exec_cmd(du_cmd).split()[0])

        part.size = bootimg_size
        part.source_file = bootimg