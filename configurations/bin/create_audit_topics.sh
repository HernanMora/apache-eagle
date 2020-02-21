#!/bin/bash

display_usage() { 
	echo "This script must be run with super-user privileges." 
	echo -e "\nUsage:\ $0 SITE_ID \n" 
} 

if [  $# -le 0 ]; then 
  display_usage
  exit 1
fi 

if [[ ( $# == "--help") ||  $# == "-h" ]]; then 
  display_usage
  exit 0
fi 

SITE_ID=$1
AUDIT_LOG_TOPIC="hbase_audit_log_${SITE_ID}"
AUDIT_LOG_ENRICHED_TOPIC="hbase_audit_log_enriched_${SITE_ID}"

echo "Creating kafka topics for Eagle ... "

topic=`kafka-topics.sh --list --zookeeper $EAGLE_ZOOKEEPER_QUORUM --topic $AUDIT_LOG_TOPIC`
if [ -z $topic ]; then
        kafka-topics.sh --create --zookeeper $EAGLE_ZOOKEEPER_QUORUM --replication-factor $EAGLE_KAFKA_REPLICATION_FACTOR --partitions $EAGLE_KAFKA_PARTITIONS --topic $AUDIT_LOG_TOPIC
        if [ $? = 0 ]; then
            echo "==> Created kafka topic: $AUDIT_LOG_TOPIC successfully for Eagle"
        else
            echo "==> Failed to create required topic: $AUDIT_LOG_TOPIC, exiting"
            exit 1
        fi
else
    echo "==> Kafka topic: $AUDIT_LOG_TOPIC already exists for Eagle"
fi

topic=`kafka-topics.sh --list --zookeeper $EAGLE_ZOOKEEPER_QUORUM --topic $AUDIT_LOG_ENRICHED_TOPIC`
if [ -z $topic ]; then
        kafka-topics.sh --create --zookeeper $EAGLE_ZOOKEEPER_QUORUM --replication-factor $EAGLE_KAFKA_REPLICATION_FACTOR --partitions $EAGLE_KAFKA_PARTITIONS --topic $AUDIT_LOG_ENRICHED_TOPIC
        if [ $? = 0 ]; then
            echo "==> Created kafka topic: $AUDIT_LOG_ENRICHED_TOPIC successfully for Eagle"
        else
            echo "==> Failed to create required topic: $AUDIT_LOG_ENRICHED_TOPIC, exiting"
            exit 1
        fi
else
    echo "==> Kafka topic: $AUDIT_LOG_ENRICHED_TOPIC already exists for Eagle"
fi