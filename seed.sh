#!/bin/bash

MAPCACHE=/opt/openbasiskaart/mapcache/
THREADS=8
cd /var/opt/mapcache

echo Removing old tiles...
find . -maxdepth 1 -type d -name "osm*" -exec rm -rf {} \;
chown -R www-data:www-data .

echo Prewarming tables...
su - postgres -c 'psql -d osm' > /dev/null <<EOF
select pg_prewarm('osm_buildings');
select pg_prewarm('osm_landusages');
select pg_prewarm('osm_roads');
select pg_prewarm('osm_waterareas');
EOF

function seed() {
  local tileset=$1
  local grid=$2
  local levels=$3

  # TODO: seed extent werkt niet: -d $MAPCACHE/seed_extent.shp
  echo Seeding tileset ${tileset} levels ${levels}...
  /usr/bin/time -f "Time: %E" su www-data -s /bin/bash -c "mapcache_seed -c $MAPCACHE/mapcache.xml -t $tileset -g $grid -z $levels -n $THREADS"
}

# Seed levels 10 and 11 separately to monitor speed

seed osm rd 0,8
#seed osm rd 10,10
#seed osm rd 11,11

seed osm-g g 0,6

seed osm-hq rd-hq 0,6
#seed osm-hq rd-hq 10,10
#seed osm-hq rd-hq 11,11 # space: x G

