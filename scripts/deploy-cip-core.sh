#!/bin/sh

set -e

if [ "$CI_COMMIT_REF_NAME" != "master" ]; then
	exit 0
fi

PATH=$PATH:~/.local/bin

if ! which aws 2>&1 >/dev/null; then
	echo "Installing awscli..."
	pip3 install wheel
	pip3 install awscli
fi

RELEASE=$1
TARGET=$2
EXTENSION=$3
DTB=$4

BASE_FILENAME=cip-core-image-cip-core-$RELEASE-$TARGET
if [ "${EXTENSION}" != "base" ] ; then
	if [ "${EXTENSION}" = "security" ] ; then
		BASE_FILENAME=cip-core-image-$EXTENSION-cip-core-$RELEASE-$TARGET
	else
		BASE_FILENAME=cip-core-image-cip-core-$RELEASE-$TARGET-$EXTENSION
	fi
fi

BASE_PATH=build/tmp/deploy/images/$TARGET/$BASE_FILENAME

if [ -f $BASE_PATH.wic.img ] ; then
	echo "Compressing $BASE_FILENAME.wic.img..."
	xz -9 -k $BASE_PATH.wic.img

	echo "Uploading artifacts..."
	aws s3 cp --no-progress $BASE_PATH.wic.img.xz s3://download.cip-project.org/cip-core/$TARGET/
fi

if [ -f $BASE_PATH.tar.gz ]; then
	echo "Uploading artifacts..."
	aws s3 cp --no-progress $BASE_PATH.tar.gz s3://download.cip-project.org/cip-core/$TARGET/
fi

KERNEL_IMAGE=$BASE_PATH-vmlinuz
# iwg20m workaround
if [ -f build/tmp/deploy/images/$TARGET/zImage ]; then
	KERNEL_IMAGE=build/tmp/deploy/images/$TARGET/zImage
fi
aws s3 cp --no-progress $KERNEL_IMAGE s3://download.cip-project.org/cip-core/$TARGET/
aws s3 cp --no-progress $BASE_PATH-initrd.img s3://download.cip-project.org/cip-core/$TARGET/

if [ "$DTB" != "none" ]; then
	aws s3 cp --no-progress build/tmp/work/cip-core-*/linux-cip*/*/linux-cip-*/debian/linux-image-cip*/usr/lib/linux-image-*/$DTB s3://download.cip-project.org/cip-core/$TARGET/
fi
