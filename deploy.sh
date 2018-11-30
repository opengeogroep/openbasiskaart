#!/bin/bash
BASEPATH=`realpath $(dirname $0)`
cd /mnt/data/mapcache
echo Removing old backups...
rm -rf *.bak
set -e
echo Deploying imposm tables...
imposm --table-prefix=osm_import_ --table-prefix-production=osm_new_ --connection postgis://osm:osm@localhost/osm --deploy-production-tables
echo Creating generalized waterways...
PGPASSWORD=osm  psql -h localhost -d osm -U osm -c 'CREATE TABLE osm_new_waterways_gen0 AS SELECT id, osm_id, name, type, st_simplifypreservetopology(geometry, 200::double precision) AS geometry FROM osm_new_waterways;'
PGPASSWORD=osm  psql -h localhost -d osm -U osm -c 'CREATE TABLE osm_new_waterways_gen1 AS SELECT id, osm_id, name, type, st_simplifypreservetopology(geometry, 50::double precision) AS geometry FROM osm_new_waterways;'
echo Moving old tilesets to backup...
for file in *; do [ -d "$file" ] && mv "$file" "$file.bak"; done
echo Creating links for higher nb levels...
mkdir -p osm-nb-hq/rd-hq
mkdir -p osm-hq/rd-hq
cd osm-nb-hq/rd-hq
ln -s ../../osm-hq/rd-hq/00
ln -s ../../osm-hq/rd-hq/01
ln -s ../../osm-hq/rd-hq/02
ln -s ../../osm-hq/rd-hq/03
ln -s ../../osm-hq/rd-hq/04
ln -s ../../osm-hq/rd-hq/05
ln -s ../../osm-hq/rd-hq/06
ln -s ../../osm-hq/rd-hq/07
ln -s ../../osm-hq/rd-hq/08
cd ../..
mkdir -p osm-nb/rd
mkdir -p osm/rd
cd osm-nb/rd
ln -s ../../osm/rd/00
ln -s ../../osm/rd/01
ln -s ../../osm/rd/02
ln -s ../../osm/rd/03
ln -s ../../osm/rd/04
ln -s ../../osm/rd/05
ln -s ../../osm/rd/06
ln -s ../../osm/rd/07
ln -s ../../osm/rd/08
cd ../..
echo Seeding tileset osm...
su www-data -s /bin/bash -c "mapcache_seed -c mapcache.xml -d $BASEPATH/seeding/mapcache_seed_extent.shp -t osm -g rd -z 0,9 -n 16" >/dev/null
echo Seeding tileset osm-nb...
su www-data -s /bin/bash -c "mapcache_seed -c mapcache.xml -d $BASEPATH/seeding/mapcache_seed_extent.shp -t osm-nb -g rd -z 0,8 -n 16" >/dev/null
echo Seeding tileset osm-hq...
su www-data -s /bin/bash -c "mapcache_seed -c mapcache.xml -d $BASEPATH/seeding/mapcache_seed_extent.shp -t osm-hq -g rd-hq -z 0,8 -n 16" >/dev/null


