#!/bin/bash


#if [ "X${GOCD_LOCAL_DOCKERENGINE}" == "Xtrue" ];then
#	GOCD_AGENT_AUTOENABLE_RESOURCES=$(extend_list ${GOCD_AGENT_AUTOENABLE_RESOURCES} docker-engine)
#fi

#consul-template -once -template "/etc/consul-templates/gocd/autoregister.properties.ctmpl:/opt/go-agent/config/autoregister.properties"

/opt/go-agent/agent.sh
