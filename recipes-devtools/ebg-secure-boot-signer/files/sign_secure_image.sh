#!/bin/sh
#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2020-2022
#
# Authors:
#  Quirin Gylstorff <quirin.gylstorff@siemens.com>
#  Jan Kiszka <jan.kiszka@siemens.com>
#
# SPDX-License-Identifier: MIT
#

set -e

signee=$1
signed=$2

usage(){
    echo "sign with image keys"
    echo "$0 signee signed"
    echo "signee: path to the image to be signed"
    echo "signed: path to store the signed image"
}

if [ -z "$signee" ] || [ -z "$signed" ]; then
    usage
    exit 1
fi

keydir=/usr/share/secure-boot-secrets

sbsign --key ${keydir}/secure-boot.key --cert ${keydir}/secure-boot.pem --output $signed $signee
