#!/bin/sh

set -e

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
REF=$5

BASE_FILENAME=cip-core-image-cip-core-$RELEASE-$TARGET
if [ "${EXTENSION}" != "none" ] ; then
	if [ "${EXTENSION}" = "security" ] ; then
		BASE_FILENAME=cip-core-image-$EXTENSION-cip-core-$RELEASE-$TARGET
	else
		BASE_FILENAME=cip-core-image-cip-core-$RELEASE-$TARGET-$EXTENSION
	fi
fi

BASE_PATH=build/tmp/deploy/images/$TARGET/$BASE_FILENAME
S3_TARGET=s3://download2.cip-project.org/cip-core/$REF/$TARGET/

if [ -f $BASE_PATH.wic ] ; then
	echo "Compressing $BASE_FILENAME.wic..."
	xz -9 -k $BASE_PATH.wic

	echo "Uploading artifacts..."
	aws s3 cp --no-progress --acl public-read $BASE_PATH.wic.xz ${S3_TARGET}
fi

if [ -f $BASE_PATH.tar.gz ]; then
	echo "Uploading artifacts..."
	aws s3 cp --no-progress --acl public-read $BASE_PATH.tar.gz ${S3_TARGET}
fi

KERNEL_IMAGE="$BASE_PATH-vmlinu[xz]"
# iwg20m workaround
if [ -f build/tmp/deploy/images/$TARGET/zImage ]; then
	KERNEL_IMAGE=build/tmp/deploy/images/$TARGET/zImage
fi
aws s3 cp --no-progress --acl public-read $KERNEL_IMAGE ${S3_TARGET}
aws s3 cp --no-progress --acl public-read $BASE_PATH-initrd.img ${S3_TARGET}

if [ "$DTB" != "none" ]; then
	aws s3 cp --no-progress --acl public-read build/tmp/deploy/images/*/$DTB ${S3_TARGET}
fi
