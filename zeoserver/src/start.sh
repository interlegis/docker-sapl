#!/bin/bash

_terminate() {
  $ZEOHOME/bin/zeoctl stop
  kill -TERM $child 2>/dev/null
}

trap _terminate SIGTERM SIGINT

tempstoragecheck() {
  if [ "${TEMPSTORAGE,,}" == "true" ]; then
    
    zeoconf=$ZEOHOME/etc/zeo.conf

    echo "
%import tempstorage
<temporarystorage temp>
  name temporary storage for sessioning
</temporarystorage>" >> $zeoconf
 
  fi
}

tempstoragecheck

$ZEOHOME/bin/zeoctl start
$ZEOHOME/bin/zeoctl logtail &

child=$!
wait "$child"
