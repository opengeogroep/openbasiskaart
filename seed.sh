#!/bin/bash

MAPCACHE=/opt/openbasiskaart/mapcache/
THREADS=6
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

  local tiles_dir=/var/opt/mapcache/$tileset
  mkdir -p $tiles_dir; chown www-data:www-data $tiles_dir
  local size_before=`du -s --block-size=1 $tiles_dir | cut -f 1`
  echo Seeding tileset ${tileset} levels ${levels}...
  # mapcache_seed from unstable PPA 1.14.0-2~jammy0 segfaults when using -d argument to seed extent from datasource
  /usr/bin/time -f "Time: %E" su www-data -s /bin/bash -c "mapcache_seed -c $MAPCACHE/mapcache.xml --non-interactive -t $tileset -g $grid -z $levels -d $MAPCACHE/seed_extent.shp -n $THREADS | tail -n 1"
  local size_after=`du -s --block-size=1 $tiles_dir | cut -f 1`
  echo -n "Seed disk usage increase: "
  echo $((size_after - size_before)) | numfmt --to=iec
}

# Seed levels 10 and 11 separately to monitor speed

seed osm rd 0,9
seed osm rd 10,10
seed osm rd 11,11

seed osm-g g 0,9

seed osm-hq rd-hq 0,9
seed osm-hq rd-hq 10,10
seed osm-hq rd-hq 11,11

df -h /var/opt/mapcache

