#!/bin/bash

echo "Checking Eagle configuration..."

if [ ! -f "$EAGLE_CONF_DIR/server.yml" ]; then
  echo "No Eagle server configuration file found. Generating the Eagle server configuration file..."
  cp "$SERVICE_CONFIGURATIONS/server.yml" "$EAGLE_CONF_DIR/server.yml"
else
  echo "Eagle Server Configuration file found..."
fi


if [ ! -f "$EAGLE_CONF_DIR/eagle.conf" ]; then
  echo "No Eagle service configuration file found. Generating the Eagle service configuration file..."
  cp "$SERVICE_CONFIGURATIONS/eagle.conf" "$EAGLE_CONF_DIR/eagle.conf"

  sed -i -e "s|%EAGLE_ZOOKEEPER_QUORUM%|$EAGLE_ZOOKEEPER_QUORUM|g" "$EAGLE_CONF_DIR/eagle.conf"
  sed -i -e "s|%EAGLE_DB_USERNAME%|$EAGLE_DB_USERNAME|g" "$EAGLE_CONF_DIR/eagle.conf"
  sed -i -e "s|%EAGLE_DB_PASSWORD%|$EAGLE_DB_PASSWORD|g" "$EAGLE_CONF_DIR/eagle.conf"
  sed -i -e "s|%EAGLE_DB_DATABASE%|$EAGLE_DB_DATABASE|g" "$EAGLE_CONF_DIR/eagle.conf"
  sed -i -e "s|%EAGLE_DB_HOSTNAME%|$EAGLE_DB_HOSTNAME|g" "$EAGLE_CONF_DIR/eagle.conf"
  sed -i -e "s|%EAGLE_DB_PORT%|$EAGLE_DB_PORT|g" "$EAGLE_CONF_DIR/eagle.conf"

else
  echo "Eagle service Configuration file found..."
fi

if [ ! -f "/.deploy_db" ]; then
  wait-for-it.sh $EAGLE_DB_HOSTNAME:$EAGLE_DB_PORT -t 30
  ret=`echo 'SHOW TABLES;' | mysql -h $EAGLE_DB_HOSTNAME -P $EAGLE_DB_PORT -u $EAGLE_DB_USERNAME --password="$EAGLE_DB_PASSWORD" $EAGLE_DB_DATABASE`
  if [ $? -eq 0 ]; then
    echo "Connected to database successfully!"
    found=0
    for table in $ret; do
      if [ "$table" == "applications" ]; then
        found=1
        break
      fi
    done
    if [ $found -eq 1 ]; then
        echo "Database $EAGLE_DB_DATABASE available"
        touch /.deploy_db
    else
      echo "Importing DDL to database..."
      ret=`mysql -h $EAGLE_DB_HOSTNAME -P $EAGLE_DB_PORT -u $EAGLE_DB_USERNAME --password="$EAGLE_DB_PASSWORD" $EAGLE_DB_DATABASE 2>&1 < $EAGLE_DIR/doc/metadata-ddl.sql`
      if [ $? -eq 0 ]; then
          echo "Imported $EAGLE_DIR/doc/metadata-ddl.sql successfully"
          touch /.deploy_db
      else
          echo "ERROR: Importing $EAGLE_DIR/doc/metadata-ddl.sql failed:"
          echo $ret
      fi
    fi
  else
    echo "ERROR: Connecting to database failed:"
    echo $ret
  fi
fi