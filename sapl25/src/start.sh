#!/bin/bash

_terminate() {
  $INSTALLDIR/instances/sapl25/bin/zopectl stop
  kill -TERM $child 2>/dev/null
}

trap _terminate SIGTERM SIGINT

$INSTALLDIR/instances/sapl25/bin/zopectl start
$INSTALLDIR/instances/sapl25/bin/zopectl logtail &

child=$!
wait "$child"
