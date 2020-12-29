#!/bin/bash
WWW=/var/www/openbasiskaart/website/
LOGS=/var/log/apache2
mkdir /var/lib/goaccess 2>/dev/null
# Parse all data including the hosts and referer panels hidden from the public html report. Only visible with terminal access with 'goaccess --restore'
goaccess $LOGS/openbasiskaart-goaccess.log $LOGS/openbasiskaart-ssl-goaccess.log --restore --persist --process-and-exit
# Generate privacy-friendly public reports
goaccess --restore --ignore-panel=HOSTS --ignore-panel=REFERRERS --ignore-panel=REFERRING_SITES --output=$WWW/report.html --output=$WWW/report.json --no-progress

