#!/bin/bash

echo "Checking Storm configuration..."

if [ ! -f "$STORM_CONF_DIR/storm.yaml" ]; then
  echo "No configuration file found. Generating the Storm configuration file..."
  cp "$SERVICE_CONFIGURATIONS/storm.yaml" "$STORM_CONF_DIR/storm.yaml"

  sed -i -e "s|^\(java.library.path:\)\(.*\)$|\1 $STORM_JAVA_LIB|g" "$STORM_CONF_DIR/storm.yaml"
  sed -i -e "s|^\(storm.log.dir:\)\(.*\)$|\1 $STORM_LOG_DIR|g" "$STORM_CONF_DIR/storm.yaml"
  sed -i -e "s|^\(storm.local.dir:\)\(.*\)$|\1 $STORM_DATA_DIR|g" "$STORM_CONF_DIR/storm.yaml"
  sed -i -e "s|^\(storm.zookeeper.servers:\)\(.*\)$|\1 $STORM_ZOOKEEPER_SERVERS|g" "$STORM_CONF_DIR/storm.yaml"
    
else
  echo "Configuration file found..."
fi
