#!/bin/bash

chown -R gocd /opt/go-agent/
if [[ -e /var/run/docker.sock ]];then
   chown gocd /var/run/docker.sock
fi
