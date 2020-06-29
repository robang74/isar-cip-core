#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2020
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT
#

SOURCE_IMAGE_FILE ?= "${WIC_IMAGE_FILE}"
EXTRACT_PARTITIONS ?= "img4"

do_extract_partition () {
    for PARTITION in ${EXTRACT_PARTITIONS}; do
        rm -f ${DEPLOY_DIR_IMAGE}/${PARTITION}.gz
        PART_START=$(fdisk -lu ${SOURCE_IMAGE_FILE} | grep ${PARTITION} | awk '{ print $2 }'  )
        PART_END=$(fdisk -lu ${SOURCE_IMAGE_FILE} | grep ${PARTITION} | awk '{ print $3 }'  )
        PART_COUNT=$(expr ${PART_END} - ${PART_START} + 1 )

        dd if=${SOURCE_IMAGE_FILE} of=${DEPLOY_DIR_IMAGE}/${PARTITION} bs=512 skip=${PART_START} count=${PART_COUNT}

        gzip ${DEPLOY_DIR_IMAGE}/${PARTITION}
    done
}
