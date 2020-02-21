#!/bin/bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions

function error() {
SCRIPT="$0"           # script name
LASTLINE="$1"         # line of error occurrence
LASTERR="$2"          # error code
echo "ERROR exit from ${SCRIPT} : line ${LASTLINE} with exit code ${LASTERR}"
exit 1
}

trap 'error ${LINENO} ${?}' ERR

configure_storm.sh
configure_eagle.sh

echo "Starting Eagle Service ... "
eagle-server.sh start

echo "Starting Storm Services ... "
nohup storm nimbus > /var/log/storm/storm-nimbus.log 2>&1
nohup storm supervisor > /var/log/storm/storm-supervisor.log 2>&1
nohup storm ui > /var/log/storm/storm-ui.log 2>&1

#EAGLE_TOPOLOGY_JAR=`ls ${EAGLE_DIR}/lib/eagle-topology-*-assembly.jar`
#storm jar "$EAGLE_TOPOLOGY_JAR" org.apache.storm.starter.WordCountTopology topology

tail -f $EAGLE_DIR/log/eagle-server.out