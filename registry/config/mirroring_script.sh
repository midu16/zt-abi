#!/bin/bash

# defining the global variables
export LOCAL_REPO="ocp-release"
export PULLSECRET_FILE=$1
# we are going to use the localhost and port 5000 because this mirror will happen inside the registry container
export LOCAL_REG="$2:5051"
export OCP_VERSION=$3
export UPSTREAM_REPO=$(curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$OCP_VERSION/release.txt | grep 'Pull From: quay.io' | awk -F ' ' '{print $3}')
oc adm release mirror -a ${PULLSECRET_FILE} --from=$UPSTREAM_REPO --to-release-image=$LOCAL_REG/$LOCAL_REPO:${VERSION} --to=$LOCAL_REG/$LOCAL_REPO --insecure=true