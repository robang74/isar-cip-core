#!/bin/sh
name=${SB_NAME:-snakeoil}
keydir=${SB_KEYDIR:-./keys}
if [ ! -d  ${keydir} ]; then
    mkdir -p ${keydir}
fi
inkey=${INKEY:-/usr/share/ovmf/PkKek-1-snakeoil.key}
incert=${INCERT:-/usr/share/ovmf/PkKek-1-snakeoil.pem}
nick_name=${IN_NICK:-snakeoil}
TMP=$(mktemp -d)
mkdir -p ${keydir}/${name}certdb
certutil -N --empty-password -d ${keydir}/${name}certdb
openssl pkcs12 -export -out ${TMP}/foo_key.p12 -inkey $inkey  -in $incert  -name $nick_name
pk12util -i ${TMP}/foo_key.p12 -d ${keydir}/${name}certdb
cp $incert ${keydir}/$(basename $incert)
rm -rf $TMP
