#!/bin/bash

: ${HOME_DIR:=/home}


if [[ -d "/opt/qnib/ucp/bundles/" ]];then
  for b in $(ls /opt/qnib/ucp/bundles/*.zip);do
    UCP_USER=$(echo ${b} |sed -e 's/\.zip//'|awk -F\- '{print $NF}')
    mkdir -p ${HOME_DIR}/${UCP_USER}/bundle
    rm -rf ${HOME_DIR}/${UCP_USER}/bundle/*
    cd ${HOME_DIR}/${UCP_USER}/bundle/
    echo ">> Unzip '${b}' into '${HOME_DIR}/${UCP_USER}/bundle/'"
    unzip -q ${b}
    chmod 644 ${HOME_DIR}/${UCP_USER}/bundle/key.pem
    chmod 644 ${HOME_DIR}/${UCP_USER}/bundle/kube.yml 
  done
fi
