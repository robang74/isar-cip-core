#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT
#

EXTRACT_PARTITIONS ?= "${IMAGE_FULLNAME}.wic.img.p4"

do_compress_swupdate_rootfs () {
    for PARTITION in ${EXTRACT_PARTITIONS}; do
        if [ -e ${DEPLOY_DIR_IMAGE}/${PARTITION} ]; then
            rm -f ${DEPLOY_DIR_IMAGE}/${PARTITION}.gz
            gzip ${DEPLOY_DIR_IMAGE}/${PARTITION}
        fi
    done
}
