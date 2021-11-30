#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2021
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#
# SPDX-License-Identifier: MIT
#
IMAGER_INSTALL += "cryptsetup"

VERITY_IMAGE_TYPE ?= "squashfs"
VERITY_INPUT_IMAGE ?= "${IMAGE_FULLNAME}.${VERITY_IMAGE_TYPE}.img"
VERITY_OUTPUT_IMAGE ?= "${IMAGE_FULLNAME}.${VERITY_IMAGE_TYPE}.verity.img"
VERITY_IMAGE_METADATA = "${VERITY_OUTPUT_IMAGE}.metadata"
VERITY_HASH_BLOCK_SIZE ?= "1024"
VERITY_DATA_BLOCK_SIZE ?= "1024"

create_verity_env_file() {

    local ENV="${DEPLOY_DIR_IMAGE}/${IMAGE_FULLNAME}.verity.env"
    rm -f $ENV

    local input="${WORKDIR}/${VERITY_IMAGE_METADATA}"
    # remove header from verity meta data
    sed -i '/VERITY header information for/d' $input
    IFS=":"
    while read KEY VAL; do
        printf '%s=%s\n' \
            "$(echo "$KEY" | tr '[:lower:]' '[:upper:]' | sed 's/ /_/g')" \
            "$(echo "$VAL" | tr -d ' \t')" >> $ENV
    done < $input
}

verity_setup() {
    rm -f ${DEPLOY_DIR_IMAGE}/${VERITY_OUTPUT_IMAGE}
    rm -f ${WORKDIR}/${VERITY_IMAGE_METADATA}

    cp -a ${DEPLOY_DIR_IMAGE}/${VERITY_INPUT_IMAGE} ${DEPLOY_DIR_IMAGE}/${VERITY_OUTPUT_IMAGE}

    image_do_mounts
    sudo chroot "${BUILDCHROOT_DIR}" /sbin/veritysetup format \
        --hash-block-size "${VERITY_HASH_BLOCK_SIZE}"  \
        --data-block-size "${VERITY_DATA_BLOCK_SIZE}"  \
        --data-blocks "${VERITY_DATA_BLOCKS}" \
        --hash-offset "${VERITY_INPUT_IMAGE_SIZE}" \
        "${PP_DEPLOY}/${VERITY_OUTPUT_IMAGE}" \
        "${PP_DEPLOY}/${VERITY_OUTPUT_IMAGE}" \
        >"${WORKDIR}/${VERITY_IMAGE_METADATA}"

    echo "Hash offset:    	${VERITY_INPUT_IMAGE_SIZE}" \
        >>"${WORKDIR}/${VERITY_IMAGE_METADATA}"
}

do_verity_image[cleandirs] = "${WORKDIR}/verity"
python do_verity_image() {
    import os

    image_file = os.path.join(
        d.getVar("DEPLOY_DIR_IMAGE"),
        d.getVar("VERITY_INPUT_IMAGE")
    )
    data_block_size = int(d.getVar("VERITY_DATA_BLOCK_SIZE"))
    size = os.stat(image_file).st_size
    assert size % data_block_size == 0, f"image is not well-sized!"
    d.setVar("VERITY_INPUT_IMAGE_SIZE", str(size))
    d.setVar("VERITY_DATA_BLOCKS", str(size // data_block_size))

    bb.build.exec_func('verity_setup', d)
    bb.build.exec_func('create_verity_env_file', d)
}
addtask verity_image before do_image after do_image_tools
