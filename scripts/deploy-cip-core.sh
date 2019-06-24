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

TARGET=$1
DTB=$2

echo "Compressing cip-core-image-cip-core-$TARGET.wic.img..."
xz -9 -k build/tmp/deploy/images/$TARGET/cip-core-image-cip-core-$TARGET.wic.img

echo "Uploading artifacts..."
aws s3 cp --no-progress build/tmp/deploy/images/$TARGET/cip-core-image-cip-core-$TARGET.wic.img.xz s3://download.cip-project.org/cip-core/$TARGET/

aws s3 cp --no-progress build/tmp/deploy/images/$TARGET/cip-core-image-cip-core-$TARGET-vmlinuz-* s3://download.cip-project.org/cip-core/$TARGET/
aws s3 cp --no-progress build/tmp/deploy/images/$TARGET/cip-core-image-cip-core-$TARGET-initrd.img-* s3://download.cip-project.org/cip-core/$TARGET/

if [ -n "$DTB" ]; then
	aws s3 cp --no-progress build/tmp/work/cip-core-*/linux-cip-*/repack/linux-image/usr/lib/linux-image-*/$DTB s3://download.cip-project.org/cip-core/$TARGET/
fi
