#!/bin/bash

_terminate() {
  $ZEOHOME/bin/zeoctl stop
  kill -TERM $child 2>/dev/null
}

trap _terminate SIGTERM SIGINT

$ZEOHOME/bin/zeoctl start
$ZEOHOME/bin/zeoctl logtail &

child=$!
wait "$child"
