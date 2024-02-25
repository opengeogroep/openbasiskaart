#!/bin/bash

PBF_URL=https://download.geofabrik.de/europe/netherlands/utrecht-latest.osm.pbf
#PBF_URL=https://download.geofabrik.de/europe-latest.osm.pbf
#PBF_URL=https://download.geofabrik.de/europe/netherlands-latest.osm.pbf
PBF=/var/opt/osm/${PBF_URL##*/}
ENABLE_BACKUP=true

if [ -s $PBF ]; then
  TIME_COND="--time-cond $PBF"
fi
rm /tmp/curl* 2> /dev/null
echo Downloading ${PBF_URL}...
curl --silent --fail --max-time 3600 --retry 3 --retry-delay 1 \
  --output $PBF \
  --remote-time \
  --show-error \
  --write-out "HTTP code: %{http_code}, downloaded %{size_download} bytes at %{speed_download} bytes/s in %{time_total} s." \
  $TIME_COND \
  --location $PBF_URL > /tmp/curl-stdout 2> /tmp/curl-stderr

if [[ $? -ne 0 ]]; then
  echo "Failed to download from $PBF_URL: `cat /tmp/curl-stderr`"
  quit 1
fi

CURL_STDOUT=`cat /tmp/curl-stdout`
echo $CURL_STDOUT
[[ $CURL_STDOUT =~ HTTP\ code:\ ([0-9]*) ]] && HTTP_CODE=${BASH_REMATCH[1]}

# Quit when PBF is not modified
if [[ $HTTP_CODE -eq 304 ]]; then
  exit 0
elif [[ $HTTP_CODE -ne 200 ]]; then
  echo "HTTP download failed, abort"
  exit 1
fi

echo Downloaded new OSM PBF data, starting import at `date`...

IMPOSM=`find /opt -type f -executable -name imposm`
$IMPOSM import  \
  -config /opt/openbasiskaart/imposm/config.json \
  -read $PBF \
  -overwritecache \
  -diff \
  -write \
  -optimize \
  -deployproduction
$IMPOSM import -config /opt/openbasiskaart/imposm/config.json -removebackup

if [[ $ENABLE_BACKUP == "true" ]]; then
  echo Creating database backup...
  rm -rf /var/opt/osm/backup 2>/dev/null; mkdir /var/opt/osm/backup; chown postgres:postgres /var/opt/osm/backup
  # --compress=zstd not available in postgres 14 yet
  /usr/bin/time -f "Time: %E" su - postgres -c 'pg_dump -Fd -f /var/opt/osm/backup --jobs=4 --compress=none -d osm'
  echo Compressing backup...
  /usr/bin/time -f "Time: %E" zstdmt --rm -r --no-progress /var/opt/osm/backup
fi

echo Reseeding tiles...
BASEPATH=`realpath $(dirname $0)`
$BASEPATH/seed.sh

echo
echo Finished update on `date`
