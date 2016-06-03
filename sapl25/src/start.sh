#!/bin/bash

_terminate() {
  $INSTALLDIR/instances/sapl25/bin/zopectl stop
  kill -TERM $child 2>/dev/null
}

trap _terminate SIGTERM SIGINT

mysqlcheck() {
  # Wait for MySQL to be available...
  COUNTER=10
  until mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -e "show databases" 2>/dev/null; do
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
      sleep 2
    done
    echo "Database is empty. Importing base tables..."
    mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < $INSTALLDIR/instances/sapl25/Products/ILSAPL/instalacao/sapl.sql && echo "Import done."
  fi 
}

zopesaplcheck() {
  if [ ! -f "$INSTALLDIR/.saplcreated" ]; then
    echo "Configuring SAPL..."
    $INSTALLDIR/instances/sapl25/bin/zopectl run $INSTALLDIR/sapl_create.py 2>/dev/null && \
    touch "$INSTALLDIR/.saplcreated" && \
    echo "SAPL configured successfully."
  fi 
}

zeoclientcheck() {
  if [ "${ZEO_CLIENT,,}" == "true" ]; then
    dbmain="
    mount-point /
    cache-size 5000
    <zeoclient>
     server $ZEO_ADDRESS
     storage 1
     name zeostorage
     var \$INSTANCE/var
   </zeoclient>"

    dbtemp="
    mount-point /temp_folder
    container-class Products.TemporaryFolder.TemporaryContainer
    cache-size 5000
    <zeoclient>
     server $ZEO_ADDRESS
     storage temp
     name zeostorage
     var \$INSTANCE/var
   </zeoclient>"

    zopeconf=$INSTALLDIR/instances/sapl25/etc/zope.conf
   
    awk -vcontent="$dbmain" '
      BEGIN       {p=1}
      /^<zodb_db main>/    {print;print content;p=0}
      /^<\/zodb_db>/    {p=1}
      p' $zopeconf > "$zopeconf.tmp1"
    
    awk -vcontent="$dbtemp" '
      BEGIN       {p=1}
      /^<zodb_db temporary>/    {print;print content;p=0}
      /^<\/zodb_db>/    {p=1}
      p' "$zopeconf.tmp1" > "$zopeconf.tmp2"

    mv "$zopeconf.tmp2" $zopeconf
    rm "$zopeconf.tmp1"

    #Remove zodb_db documentos
    sed -i '/<zodb_db documentos>/,/<\/zodb_db>/d' $zopeconf

  fi 
}

zeoclientcheck
mysqlcheck
zopesaplcheck

$INSTALLDIR/instances/sapl25/bin/zopectl start
$INSTALLDIR/instances/sapl25/bin/zopectl logtail &

child=$!
wait "$child"
