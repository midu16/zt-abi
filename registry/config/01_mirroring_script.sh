#!/bin/bash

# installing all required packages
dnf -y install podman httpd httpd-tools jq skopeo libseccomp-devel podman-compose
# exporting the env variables
export PATH=/root/bin:$PATH
export REGISTRY_NAME="inbacrnrdl0100.offline.oxtechnix.lan"
export REGISTRY_USER={{ disconnected_user if disconnected_user != None else 'pi' }}
export REGISTRY_PASSWORD={{ disconnected_password if disconnected_password != None else 'raspberry' }}
export PATH="/apps/registry"
#creating the directory structure
mkdir -p ${PATH}/{auth,certs,data}
#generating the certs
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${PATH}/certs/domain.key -x509 -days 3650 -out ${PATH}/certs/domain.crt -subj "/C=AT/ST=Wien/L=Vienna/O=oxtechnix/OU=Guitar/CN=$REGISTRY_NAME" -addext "subjectAltName=DNS:$REGISTRY_NAME"
cp ${PATH}/certs/domain.crt /etc/pki/ca-trust/source/anchors/
# adding certs to localhost
update-ca-trust extract
htpasswd -bBc ${PATH}/auth/htpasswd ${REGISTRY_USER} ${REGISTRY_PASSWORD}
