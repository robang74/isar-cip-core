#!/bin/sh
set -e
set -x
signee=$1
signed=$2

usage(){
    echo "sign with debian snakeoil"
    echo "$0 signee signed"
    echo "signee: path to the image to be signed"
    echo "signed: path to store the signed image"
}


if [ -z "$signee" ] || [ -z "$signed" ]; then
    usage
    exit 1
fi

name=snakeoil
keydir=$(mktemp -d)
inkey=/usr/share/ovmf/PkKek-1-snakeoil.key
incert=/usr/share/ovmf/PkKek-1-snakeoil.pem
nick_name=snakeoil
TMP=$(mktemp -d)
mkdir -p ${keydir}/${name}certdb
certutil -N --empty-password -d ${keydir}/${name}certdb
openssl pkcs12 -export -passin pass:"snakeoil" -passout pass: -out ${TMP}/foo_key.p12 -inkey $inkey  -in $incert  -name $nick_name
pk12util -W "" -i ${TMP}/foo_key.p12 -d ${keydir}/${name}certdb
cp $incert ${keydir}/$(basename $incert)
rm -rf $TMP

pesign --force --verbose --padding -n ${keydir}/${name}certdb -c "$nick_name" -s -i $signee -o $signed
sbverify --cert $incert $signed
rm -rf $keydir
exit 0
