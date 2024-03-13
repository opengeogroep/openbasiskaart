#!/bin/bash
BASEPATH=`realpath $(dirname $0)`
flock -w 0 /var/run/obk-update.lck -c "$BASEPATH/update.sh 2>&1 | tee /tmp/obk-update.log"
if [ $? -eq 1 ]; then
  echo "Update lockfile exists, still running. Output of running process:"
  echo
  cat /tmp/obk-update.log
fi
