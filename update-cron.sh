#!/bin/bash
BASEPATH=`realpath $(dirname $0)`
flock -w 0 /var/run/obk-update.lck -c "$BASEPATH/update.sh 2>&1 | tee /tmp/obk-update.log"
if [ $? -eq 1 ]; then
	echo 'Update proces loopt nog en kan niet opnieuw gestart worden! Output lopend proces:'
        echo
        cat /tmp/obk-update.log
fi
