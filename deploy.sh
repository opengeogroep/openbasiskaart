#!/bin/bash
set -e
BASEPATH=`realpath $(dirname $0)`
cd /mnt/data/mapcache
CURRENT=$(readlink current)
if [ "$CURRENT" = "a" ]; then OLD="b"; else OLD="a"; fi
OLD_DEVICE=`cat /proc/mounts | grep $(realpath $OLD) | cut -d ' ' -f 1`
echo Current tileset is linked to `realpath $CURRENT`
echo Clearing out old tiles in `realpath $OLD` on loop device $OLD_DEVICE...
umount $OLD
mkfs.ext4 -F -m 0 -q -O ^has_journal $OLD_DEVICE
mount $OLD
echo Deploying imposm tables...
imposm --table-prefix=osm_import_ --table-prefix-production=osm_new_ --mapping-file=/opt/basemaps/imposm-mapping.py -d osm --deploy-production-tables
echo Switching current link to emptied loop device mounted at `realpath $OLD`...
rm current
ln -s $OLD current

echo Creating links for higher nb levels...
mkdir -p current/osm-nb-hq/rd-hq
mkdir -p current/osm-hq/rd-hq
cd current/osm-nb-hq/rd-hq
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
cd ../../..
chown -R www-data:www-data current/

echo Prewarming tables...
su - postgres -c 'psql -d osm' <<EOF
select pg_prewarm('osm_new_buildings');
select pg_prewarm('osm_new_landusages');
select pg_prewarm('osm_new_roads');
select pg_prewarm('osm_new_waterareas');
EOF

echo Seeding tileset osm levels 0 through 9...
/usr/bin/time -f "Time: %E" su www-data -s /bin/bash -c "mapcache_seed -c mapcache.xml -d $BASEPATH/seeding/mapcache_seed_extent.shp -t osm -g rd -z 0,9 -n 8 | grep total"
echo Seeding tileset osm level 10...
/usr/bin/time -f "Time: %E" su www-data -s /bin/bash -c "mapcache_seed -c mapcache.xml -d $BASEPATH/seeding/mapcache_seed_extent.shp -t osm -g rd -z 10,10 -n 8 | grep total"
echo Seeding tileset osm level 11...
/usr/bin/time -f "Time: %E" su www-data -s /bin/bash -c "mapcache_seed -c mapcache.xml -d $BASEPATH/seeding/mapcache_seed_extent.shp -t osm -g rd -z 11,11 -n 8 | grep total"
echo Seeding tileset osm level 12...
/usr/bin/time -f "Time: %E" su www-data -s /bin/bash -c "mapcache_seed -c mapcache.xml -d $BASEPATH/seeding/mapcache_seed_extent.shp -t osm -g rd -z 12,12 -n 8 | grep total"


echo Seeding tileset osm-hq levels 0 through 9...
/usr/bin/time -f "Time: %E" su www-data -s /bin/bash -c "mapcache_seed -c mapcache.xml -d $BASEPATH/seeding/mapcache_seed_extent.shp -t osm-hq -g rd-hq -z 0,9 -n 8 | grep total"
echo Seeding tileset osm-hq level 10...
/usr/bin/time -f "Time: %E" su www-data -s /bin/bash -c "mapcache_seed -c mapcache.xml -d $BASEPATH/seeding/mapcache_seed_extent.shp -t osm-hq -g rd-hq -z 10,10 -n 8 | grep total"
echo Seeding tileset osm-hq level 11...
# 7.6 G schijfruimte
/usr/bin/time -f "Time: %E" su www-data -s /bin/bash -c "mapcache_seed -c mapcache.xml -d $BASEPATH/seeding/mapcache_seed_extent.shp -t osm-hq -g rd-hq -z 11,11 -n 8 | grep total"
# Niet seeden level 12, >15G schijfruimte

