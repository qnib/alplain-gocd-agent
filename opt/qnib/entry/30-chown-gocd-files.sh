#!/bin/bash

chown -R go /opt/go-agent/
if [[ -e /var/run/docker.sock ]];then
   chown go /var/run/docker.sock
fi
