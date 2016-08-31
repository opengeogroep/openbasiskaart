#!/bin/bash
# sudo apt-get install realpath xmlstarlet curl ack-grep libdatetime-format-http-perl

PBF_URL=http://download.geofabrik.de/europe-latest.osm.pbf
PBF_DIR=/mnt/data/osm
PBF=europe-latest.osm.pbf
#PBF_URL=http://127.1.1.1/x.txt
#PBF_DIR=/mnt/data/osm
#PBF=1.txt

IMPOSM_DIR=/mnt/data/imposm/

BASEPATH=`realpath $(dirname $0)`
CURL_STDERR=/tmp/curl-stderr

function quit() {
  cd $(dirname $0)
  exit $1
}

mkdir $IMPOSM_DIR 2>/dev/null

#### Step 1: Download PBF ####

# Use after curl command, use --stderr $CURL_STDERR option with curl
function check_curl_fail() {
  local CURL_EXIT_CODE=$?
  local MESSAGE=$1
  CURL_OUTPUT=`cat $CURL_STDERR`
  if [ $CURL_EXIT_CODE -ne 0 ]; then
    echo $1: $CURL_OUTPUT
    cat $STATUS_FILE
    quit 1
  fi
}

# http://stackoverflow.com/questions/5195607/checking-bash-exit-status-of-several-commands-efficiently
# trap..

mkdir $PBF_DIR 2>/dev/null
cd $PBF_DIR

TIME_COND=
if [ -s $PBF ]; then
  TIME_COND="--time-cond $PBF_DIR/$PBF"
fi
rm /tmp/curl* 2> /dev/null
curl --fail -s \
 --max-time 3600 \
 --output $PBF_DIR/$PBF \
 --remote-time \
 --show-error \
 --stderr $CURL_STDERR \
 --write-out "HTTP code: %{http_code}, downloaded %{size_download} bytes at %{speed_download} bytes/s in %{time_total} s." \
 $TIME_COND \
 --location \
 $PBF_URL > /tmp/curl-stdout
check_curl_fail "Failed to download from $PBF_URL"

CURL_STDOUT=`cat /tmp/curl-stdout`

[[ $CURL_STDOUT =~ HTTP\ code:\ ([0-9]*) ]] && HTTP_CODE=${BASH_REMATCH[1]}

# Wanneer geen nieuwe file gedownload met HTTP status 200 dan quit

if [[ $HTTP_CODE -eq 304 ]]; then
  quit 0
elif [[ $HTTP_CODE -ne 200 ]]; then
  echo HTTP status code niet 200 of 304\: $HTTP_CODE, $CURL_STDOUT
  quit 1
fi

echo HTTP status 200, nieuwe PBF data\!

cd $PBF_DIR
rm *.cache 2>/dev/null
set -e
echo Uitvoeren Imposm...
imposm --quiet --table-prefix=osm_import_ -d osm --proj=EPSG:28992 --limit-to=imposm_limit.shp -c 4 --read --write --optimize $PBF >/dev/null 
echo Deployen nieuwe gegevens...
$BASEPATH/deploy.sh


quit 0
