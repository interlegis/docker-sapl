#!/bin/bash

_terminate() {
  $INSTALLDIR/instances/sapl25/bin/zopectl stop
  kill -TERM $child 2>/dev/null
}

trap _terminate SIGTERM SIGINT

mysqlcheck() {
  # Wait for MySQL to be available...
  COUNTER=10
  until mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -e "show databases"; do
    echo "WARNING: MySQL still not up. Trying again..."
    sleep 1
    let COUNTER-=1
    if [ $COUNTER -lt 1 ]; then
      echo "ERROR: MySQL connection timed out. Aborting."
      exit 1
    fi
  done

  count=`mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -e "select count(*) from information_schema.tables where table_type='BASE TABLE' and table_schema='sapl';" | tail -1`  
  if [ "$count" == "0" ]; then
    until mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -e "show databases"; do
      echo "MySQL is unavailable - sleeping"
      sleep 1
    done
    echo "Database is empty. Importing base tables..."
    mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < $INSTALLDIR/instances/sapl25/Products/ILSAPL/instalacao/sapl.sql && echo "Import done."

    echo "Configuring SAPL..."
    $INSTALLDIR/instances/sapl25/bin/zopectl run $INSTALLDIR/sapl_create.py && echo "SAPL configured successfully."
  fi 
}

mysqlcheck

$INSTALLDIR/instances/sapl25/bin/zopectl start
$INSTALLDIR/instances/sapl25/bin/zopectl logtail &

child=$!
wait "$child"
