#!/bin/bash

ENABLE_BACKUP=true

PBF_URLS="https://download.geofabrik.de/europe/netherlands-latest.osm.pbf
https://download.geofabrik.de/europe/belgium-latest.osm.pbf
https://download.geofabrik.de/europe/germany/nordrhein-westfalen-latest.osm.pbf
https://download.geofabrik.de/europe/germany/niedersachsen-latest.osm.pbf"

NEW_PBF=${1:-0}

function download_if_newer() {
  local PBF_URL=$1
  local PBF=/var/opt/osm/pbf/${PBF_URL##*/}

  local TIME_COND=
  if [[ -f ${PBF} ]]; then
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
    exit 1
  fi

  CURL_STDOUT=`cat /tmp/curl-stdout`
  echo $CURL_STDOUT
  [[ $CURL_STDOUT =~ HTTP\ code:\ ([0-9]*) ]] && HTTP_CODE=${BASH_REMATCH[1]}

  # Quit when PBF is not modified
  if [[ $HTTP_CODE -eq 304 ]]; then
    return 0
  elif [[ $HTTP_CODE -ne 200 ]]; then
    echo "HTTP download failed, abort"
    exit 1
  fi
  NEW_PBF=1
}

while read PBF_URL; do
  download_if_newer $PBF_URL
done <<< "$PBF_URLS"

# Quit when no PBF is modified
if [[ "$NEW_PBF" -eq "0" ]]; then
  exit 0
fi

set -e
echo Downloaded new OSM PBF data, starting import at `date`...

IMPOSM=`find /opt -type f -executable -name imposm`
FIRST=1

while read PBF_URL; do
  PBF=/var/opt/osm/pbf/${PBF_URL##*/}
  if [[ "$FIRST" -eq "1" ]]; then
    CACHE_MODE=-overwritecache
    FIRST=0
  else
    CACHE_MODE=-appendcache
  fi
  $IMPOSM import  \
    -config /opt/openbasiskaart/imposm/config.json \
    -read $PBF \
    $CACHE_MODE \
    -diff
done <<< "$PBF_URLS"

$IMPOSM import \
  -config /opt/openbasiskaart/imposm/config.json \
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
