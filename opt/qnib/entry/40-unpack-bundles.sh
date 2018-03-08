#!/bin/bash

: ${HOME_DIR:=/home}


if [[ -d "/opt/qnib/ucp/bundles/" ]];then
  for b in $(ls /opt/qnib/ucp/bundles/*.zip);do
    UCP_USER=$(echo ${b} |sed -e 's/\.zip//'|awk -F\- '{print $NF}')
    if [[ ! -d ${HOME_DIR}/${UCP_USER} ]];then
      adduser -h ${HOME_DIR}/${UCP_USER} -s /bin/false -D gocd ${UCP_USER}
    fi
    mkdir -p ${HOME_DIR}/${UCP_USER}/bundle
    rm -rf ${HOME_DIR}/${UCP_USER}/bundle/*
    cd ${HOME_DIR}/${UCP_USER}/bundle/
    unzip -q ${b}
  done
fi
