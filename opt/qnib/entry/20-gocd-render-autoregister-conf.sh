#!/bin/bash

if [[ "X${GOCD_AGENT_AUTOENABLE_KEY}" == "X" ]];then
    GOCD_AGENT_AUTOENABLE_KEY=${GO_EA_AUTO_REGISTER_KEY}
fi

mkdir -p /opt/go-agent/config/
if [[ ! -f /opt/go-agent/config/autoregister.properties ]];then
  cat /opt/qnib/gocd/etc/autoregister.properties \
    |sed -e "s/GOCD_AGENT_AUTOENABLE_KEY/${GOCD_AGENT_AUTOENABLE_KEY}/" \
    |sed -e "s/GOCD_AGENT_AUTOENABLE_ENV/${GOCD_AGENT_AUTOENABLE_ENV}/" \
    |sed -e "s/GOCD_AGENT_AUTOENABLE_RESOURCES/${GOCD_AGENT_AUTOENABLE_RESOURCES}/" \
    > /opt/go-agent/config/autoregister.properties
fi

if [[ "X${GO_EA_AUTO_REGISTER_ELASTIC_AGENT_ID}" != "X" ]];then
    sed -i'' -e "s;\(#\)*agent.auto.register.elasticAgent.agentId=.*;agent.auto.register.elasticAgent.agentId=${GO_EA_AUTO_REGISTER_ELASTIC_AGENT_ID};" /opt/go-agent/config/autoregister.properties
fi
if [[ "X${GO_EA_AUTO_REGISTER_ELASTIC_PLUGIN_ID}" != "X" ]];then
    sed -i'' -e "s;\(#\)*agent.auto.register.elasticAgent.pluginId=.*;agent.auto.register.elasticAgent.pluginId=${GO_EA_AUTO_REGISTER_ELASTIC_PLUGIN_ID};" /opt/go-agent/config/autoregister.properties
fi
