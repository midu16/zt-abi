#!/bin/bash

# installing all required packages
dnf update -y && dnf -y install podman httpd httpd-tools jq skopeo libseccomp-devel podman-compose tree
# exporting the env variables
export REGISTRY_NAME="inbacrnrdl0100.offline.oxtechnix.lan"
export REGISTRY_USER='pi'
export REGISTRY_PASSWORD='raspberry'
export REGISTRTY_PATH="/apps/registry"
#creating the directory structure
mkdir -p ${REGISTRTY_PATH}/{auth,certs,data}
#generating the certs
cert_c="AT"                     # Country Name (C, 2 letter code)
cert_s="Wien"                   # Certificate State (S)
cert_l="Wien"                   # Certificate Locality (L)
cert_o="TelcoEng"               # Certificate Organization (O)
cert_ou="RedHat"                # Certificate Organizational Unit (OU)
cert_cn="${REGISTRY_NAME}"      # Certificate Common Name (CN)
openssl req \
    -newkey rsa:4096 \
    -nodes \
    -sha256 \
    -keyout /apps/registry/certs/domain.key \
    -x509 \
    -days 365 \
    -out /apps/registry/certs/domain.crt \
    -addext "subjectAltName = DNS:${REGISTRY_NAME}" \
    -subj "/C=${cert_c}/ST=${cert_s}/L=${cert_l}/O=${cert_o}/OU=${cert_ou}/CN=${cert_cn}"
cp ${REGISTRTY_PATH}/certs/domain.crt /etc/pki/ca-trust/source/anchors/
# adding certs to localhost
update-ca-trust extract
htpasswd -bBc ${REGISTRTY_PATH}/auth/htpasswd ${REGISTRY_USER} ${REGISTRY_PASSWORD}
