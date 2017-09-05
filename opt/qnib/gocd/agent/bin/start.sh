#!/bin/bash
set -x

cd /opt/go-agent/
exec java -jar /opt/go-agent/agent-bootstrapper.jar -serverUrl ${GO_SERVER_URL}
