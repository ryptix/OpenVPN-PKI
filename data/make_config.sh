#!/bin/bash
# First argument: Client identifier

OUTPUT_DIR=/etc/openvpn/client/${1}
BASE_CONFIG=/etc/openvpn/client/base.conf

if [ -n ${NAME_CA} ];then
cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${OUTPUT_DIR}/${NAME_CA}.crt \
    <(echo -e '</ca>\n<cert>') \
    ${OUTPUT_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${OUTPUT_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${OUTPUT_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${1}.ovpn
else
cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${OUTPUT_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${OUTPUT_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${OUTPUT_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${OUTPUT_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${1}.ovpn
fi

