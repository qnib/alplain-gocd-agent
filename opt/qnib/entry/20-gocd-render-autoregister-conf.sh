#!/bin/bash

mkdir -p /opt/go-agent/config/
if [[ ! -f /opt/go-agent/config/autoregister.properties ]];then
  cat /opt/qnib/gocd/etc/autoregister.properties \
    |sed -e "s/GOCD_AGENT_AUTOENABLE_KEY/${GOCD_AGENT_AUTOENABLE_KEY}/" \
    |sed -e "s/GOCD_AGENT_AUTOENABLE_ENV/${GOCD_AGENT_AUTOENABLE_ENV}/" \
    |sed -e "s/GOCD_AGENT_AUTOENABLE_RESOURCES/${GOCD_AGENT_AUTOENABLE_RESOURCES}/" \
    > /opt/go-agent/config/autoregister.properties
fi
