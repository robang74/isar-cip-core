#!/bin/sh
name=${SB_NAME:-demo}
keydir=${SB_KEYDIR:-./keys}
if [ ! -d  ${keydir} ]; then
    mkdir -p ${keydir}
fi
openssl req -new -x509 -newkey rsa:4096 -subj "/CN=${name}PK/" -outform PEM \
        -keyout ${keydir}/${name}PK.key  -out ${keydir}/${name}PK.crt  -days 3650 -nodes -sha256
openssl req -new -x509 -newkey rsa:4096 -subj "/CN=${name}KEK/" -outform PEM \
        -keyout ${keydir}/${name}KEK.key -out ${keydir}/${name}KEK.crt -days 3650 -nodes -sha256
openssl req -new -x509 -newkey rsa:4096 -subj "/CN=${name}DB/" -outform PEM \
        -keyout ${keydir}/${name}DB.key  -out ${keydir}/${name}DB.crt  -days 3650 -nodes -sha256
openssl x509 -in ${keydir}/${name}PK.crt  -out ${keydir}/${name}PK.cer  -outform DER
openssl x509 -in ${keydir}/${name}KEK.crt -out ${keydir}/${name}KEK.cer -outform DER
openssl x509 -in ${keydir}/${name}DB.crt  -out ${keydir}/${name}DB.cer  -outform DER

openssl pkcs12 -export -out ${keydir}/${name}DB.p12 \
        -in ${keydir}/${name}DB.crt -inkey ${keydir}/${name}DB.key -passout pass:

GUID=$(uuidgen --random)
echo $GUID > ${keydir}/${name}GUID

cert-to-efi-sig-list -g $GUID ${keydir}/${name}PK.crt  ${keydir}/${name}PK.esl
cert-to-efi-sig-list -g $GUID ${keydir}/${name}KEK.crt ${keydir}/${name}KEK.esl
cert-to-efi-sig-list -g $GUID ${keydir}/${name}DB.crt  ${keydir}/${name}DB.esl
rm -f ${keydir}/${name}noPK.esl
touch ${keydir}/${name}noPK.esl

sign-efi-sig-list -g $GUID  \
                  -k ${keydir}/${name}PK.key -c ${keydir}/${name}PK.crt \
                  PK ${keydir}/${name}PK.esl   ${keydir}/${name}PK.auth
sign-efi-sig-list -g $GUID  \
                  -k ${keydir}/${name}PK.key -c ${keydir}/${name}PK.crt \
                  PK ${keydir}/${name}noPK.esl ${keydir}/${name}noPK.auth
sign-efi-sig-list -g $GUID  \
                  -k ${keydir}/${name}PK.key -c ${keydir}/${name}PK.crt \
                  KEK ${keydir}/${name}KEK.esl ${keydir}/${name}KEK.auth
sign-efi-sig-list -g $GUID  \
                  -k ${keydir}/${name}PK.key -c ${keydir}/${name}PK.crt \
                  DB ${keydir}/${name}DB.esl ${keydir}/${name}DB.auth

chmod 0600 ${keydir}/${name}*.key
mkdir -p ${keydir}/${name}certdb
certutil -N --empty-password -d ${keydir}/${name}certdb

certutil -A -n 'PK' -d ${keydir}/${name}certdb -t CT,CT,CT -i ${keydir}/${name}PK.crt
pk12util -W "" -d ${keydir}/${name}certdb -i ${keydir}/${name}DB.p12
certutil -d ${keydir}/${name}certdb -A -i ${keydir}/${name}DB.crt -n "" -t u

certutil -d ${keydir}/${name}certdb -K
certutil -d ${keydir}/${name}certdb -L
