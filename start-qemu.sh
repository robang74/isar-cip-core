#!/bin/sh
#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2019
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#
# SPDX-License-Identifier: MIT
#

usage()
{
	echo "Usage: $0 ARCHITECTURE [QEMU_OPTIONS]"
	echo -e "\nSet QEMU_PATH environment variable to use a locally " \
		"built QEMU version"
	echo -e "\nSet SECURE_BOOT environment variable to boot a secure boot environment " \
		"This environment also needs the variables OVMF_VARS and OVMF_CODE set"
	exit 1
}

if grep -s -q "IMAGE_SECURE_BOOT: true" .config.yaml; then
	SECURE_BOOT="true"
fi

if [ -n "${QEMU_PATH}" ]; then
	QEMU_PATH="${QEMU_PATH}/"
fi

if [ -z "${DISTRO_RELEASE}" ]; then
	if grep -s -q "DEBIAN_BULLSEYE: true" .config.yaml; then
		DISTRO_RELEASE="bullseye"
	elif grep -s -q "DEBIAN_STRETCH: true" .config.yaml; then
		DISTRO_RELEASE="stretch"
	else
		DISTRO_RELEASE="buster"
	fi
fi

if [ -z "${TARGET_IMAGE}" ];then
	TARGET_IMAGE="cip-core-image"
	if grep -s -q "IMAGE_SECURITY: true" .config.yaml; then
		TARGET_IMAGE="cip-core-image-security"
	fi
fi

case "$1" in
	x86|x86_64|amd64)
		DISTRO_ARCH=amd64
		QEMU=qemu-system-x86_64
		QEMU_EXTRA_ARGS=" \
			-cpu qemu64 \
			-smp 4 \
			-machine q35,accel=kvm:tcg \
			-device virtio-net-pci,netdev=net"
		if [ -n "${SECURE_BOOT}" ]; then
			QEMU_EXTRA_ARGS=" \
			${QEMU_EXTRA_ARGS} -device ide-hd,drive=disk,bootindex=0"
		else
			QEMU_EXTRA_ARGS=" \
			${QEMU_EXTRA_ARGS} -device ide-hd,drive=disk"
		fi
		KERNEL_CMDLINE=" \
			root=/dev/sda"
		;;
	arm64|aarch64)
		DISTRO_ARCH=arm64
		QEMU=qemu-system-aarch64
		QEMU_EXTRA_ARGS=" \
			-cpu cortex-a57 \
			-smp 4 \
			-machine virt \
			-device virtio-serial-device \
			-device virtconsole,chardev=con -chardev vc,id=con \
			-device virtio-blk-device,drive=disk \
			-device virtio-net-device,netdev=net"
		KERNEL_CMDLINE=" \
			root=/dev/vda"
		;;
	arm|armhf)
		DISTRO_ARCH=armhf
		QEMU=qemu-system-arm
		QEMU_EXTRA_ARGS=" \
			-cpu cortex-a15 \
			-smp 4 \
			-machine virt \
			-device virtio-serial-device \
			-device virtconsole,chardev=con -chardev vc,id=con \
			-device virtio-blk-device,drive=disk \
			-device virtio-net-device,netdev=net"
		KERNEL_CMDLINE=" \
			root=/dev/vda"
		;;
	""|--help)
		usage
		;;
	*)
		echo "Unsupported architecture: $1"
		exit 1
		;;
esac

IMAGE_PREFIX="$(dirname $0)/build/tmp/deploy/images/qemu-${DISTRO_ARCH}/${TARGET_IMAGE}-cip-core-${DISTRO_RELEASE}-qemu-${DISTRO_ARCH}"

if [ -z "${DISPLAY}" ]; then
	QEMU_EXTRA_ARGS="${QEMU_EXTRA_ARGS} -nographic"
	case "$1" in
		x86|x86_64|amd64)
			KERNEL_CMDLINE="${KERNEL_CMDLINE} console=ttyS0"
	esac
fi

shift 1

if [ -n "${SECURE_BOOT}" ]; then
		ovmf_code=${OVMF_CODE:-./build/tmp/deploy/images/qemu-amd64/OVMF/OVMF_CODE_4M.secboot.fd}
		ovmf_vars=${OVMF_VARS:-./build/tmp/deploy/images/qemu-amd64/OVMF/OVMF_VARS_4M.snakeoil.fd}
		QEMU_EXTRA_ARGS=" ${QEMU_EXTRA_ARGS} \
			-global ICH9-LPC.disable_s3=1 \
			-global isa-fdc.driveA= "

		BOOT_FILES="-drive if=pflash,format=raw,unit=0,readonly=on,file=${ovmf_code} \
			-drive if=pflash,format=raw,file=${ovmf_vars} \
			-drive file=${IMAGE_PREFIX}.wic.img,discard=unmap,if=none,id=disk,format=raw"
else
		IMAGE_FILE=$(ls ${IMAGE_PREFIX}.ext4.img)

		KERNEL_FILE=$(ls ${IMAGE_PREFIX}-vmlinu* | tail -1)
		INITRD_FILE=$(ls ${IMAGE_PREFIX}-initrd.img* | tail -1)

		BOOT_FILES="-drive file=${IMAGE_FILE},discard=unmap,if=none,id=disk,format=raw \
			-kernel ${KERNEL_FILE} -append "${KERNEL_CMDLINE}" \
			-initrd ${INITRD_FILE}"
fi
${QEMU_PATH}${QEMU} \
			-m 1G -serial mon:stdio -netdev user,id=net \
			${BOOT_FILES} ${QEMU_EXTRA_ARGS} "$@"
