#!/bin/bash

echo "#####################"
echo "#### ENV"
env |sort
echo "#####################"
cd /opt/go-agent/
exec java -jar /opt/go-agent/agent-bootstrapper.jar -serverUrl ${GO_SERVER_URL} -sslVerificationMode ${GO_SSL_VERIFY_MODE}
