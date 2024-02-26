#!/bin/bash
set -e

DIR=/opt/openbasiskaart

ln -s $DIR/apache/openbasiskaart.conf /etc/apache2/sites-available/openbasiskaart.conf
ln -s $DIR/apache/openbasiskaart-ssl.conf /etc/apache2/sites-available/openbasiskaart-ssl.conf
ln -s $DIR/apache/openbasiskaart.inc /etc/apache2/openbasiskaart.inc
sudo ln -s /usr/lib/cgi-bin/mapserv /usr/lib/cgi-bin/mapserv.fcgi

mkdir -p /var/opt/mapcache
mkdir -p /var/opt/osm/imposm-cache/diff

a2dissite 000-default
a2ensite openbasiskaart
a2enmod headers cgid ssl http2
systemctl restart apache2

su postgres -c "psql -c \"create role osm password 'osm' login\""
su postgres -c "createdb --owner=osm osm"
su postgres -c "psql osm -c 'create extension postgis'"
su postgres -c "psql osm -c 'create extension pg_prewarm'"

wget https://github.com/omniscale/imposm3/releases/download/v0.11.1/imposm-0.11.1-linux-x86-64.tar.gz
tar -zx -C /opt -f imposm-0.11.1-linux-x86-64.tar.gz
rm imposm*.tar.gz

git clone https://github.com/MapServer/basemaps.git /opt/basemaps
cd /opt/basemaps
export OSM_EXTENT="359537.9429649998 6569845.304711193 809651.3949948606 7085631.462865049"
export OSM_WMS_SRS="EPSG:28992 EPSG:3857 EPSG:900913"
export OSM_FORCE_POSTGIS_EXTENT=1
make --always-make
make data

# TODO
#echo "..." >> /etc/crontab

