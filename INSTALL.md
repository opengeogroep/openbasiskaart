Installatieinstructies Openbasiskaart (Ubuntu 18.04)
====================================================

```bash
git clone https://github.com/opengeogroep/openbasiskaart.git
cd openbasiskaart

# Installeren packages
sudo apt-get install curl postgresql postgresql-10-postgis-2.4 postgresql-10-postgis-2.4-scripts apache2 libapache2-mod-fcgid libapache2-mod-mapcache mapcache-tools cgi-mapserver mapserver-bin imposm make unzip gcc

# PostgreSQL tuning niet nodig, fsync=off maakt imposm --write niet sneller

DIR=`pwd`

# Kopie van GitHub repo voor website
git clone https://github.com/opengeogroep/openbasiskaart.git /var/www/openbasiskaart
chown -R www-data:www-data /var/www/openbasiskaart

# Kopieer github update hook (zie settings openbasiskaart GitHub repo)
cp $DIR/github-update-site-webhook.sh /usr/lib/cgi-bin

# Link configuratiebestanden
ln -s $DIR/apache/openbasiskaart.conf /etc/apache2/sites-available/openbasiskaart.conf
ln -s $DIR/apache/openbasiskaart-ssl.conf /etc/apache2/sites-available/openbasiskaart-ssl.conf
ln -s $DIR/apache/openbasiskaart.inc /etc/apache2/openbasiskaart.inc
cd /usr/lib/cgi-bin; sudo ln -s mapserv mapserv.fcgi
# Maak eventueel /mnt/data een apart volume
mkdir -p /mnt/data/mapcache
ln -s $DIR/mapcache.xml /mnt/data/mapcache

# Maken loop devices voor snel switchen tiles
cd /mnt/data/mapcache
dd if=/dev/zero of=tiles_a.img bs=1024M count=30
dd if=/dev/zero of=tiles_b.img bs=1024M count=30
losetup -fP tiles_a.img
losetup -fP tiles_b.img
mkfs.ext4 -F -T news -m 0 -q -O ^has_journal /dev/loop0
mkfs.ext4 -F -T news -m 0 -q -O ^has_journal /dev/loop1
mkdir a b
ln -s a current
chown -R www-data:www-data current/
cat >> /etc/fstab <<'EOF'
/dev/loop0      /mnt/data/mapcache/a    ext4    rw,noatime,barrier=0       0       0
/dev/loop1      /mnt/data/mapcache/b    ext4    rw,noatime,barrier=0       0       0
EOF
mount a b

# Vergroten van loop device /dev/loop0 gemount op /mnt/data/mapcache/a (kan gemount blijven):
# dd if=/dev/zero of=tiles_a.img bs=1024M count=10 conv=notrunc oflag=append
# losetup -c /dev/loop0
# resize2fs /dev/loop0
# fstrim /mnt/data/mapcache/a

# ServerAlias is globaal ingesteld in openbasiskaart.conf (om warning bij herstart te vermijden), 
# daarom moet 000-default moet gedisabled worden
a2dissite 000-default
a2ensite openbasiskaart openbasiskaart-ssl
a2enmod headers cgid ssl http2
service apache2 restart

# Let op! Vanwege schijnbare memory leak in mod_mapcache in /etc/apache2/mods-enabled/mpm_event.conf:
# MaxConnectionsPerChild   2000

su - postgres -c "createuser osm"
su - postgres -c "psql -c \"alter role osm password 'osm'\""
su - postgres -c "createdb --owner=osm osm"
su - postgres -c "psql osm -c 'create extension postgis'"
su - postgres -c "psql osm -c 'create extension pg_prewarm'"

# gebruik Ubuntu imposm package; is up-to-date
#pip install  https://github.com/omniscale/imposm/tarball/master
#pip install https://github.com/omniscale/imposm/tarball/master

cd /opt
git clone https://github.com/mapserver/basemaps.git 
make data

# patch voor nb stijl
# patch voor EXTENT bij elke LAYER, omdat anders GetCap ST_Extent() doet met deze warnings:
# landuse4/landuse5: WARNING: Optional Ex_GeographicBoundingBox could not be established for this layer.  Consider setting the EXTENT in the LAYER object, or wms_extent metadata. Also check that your data exists in the DATA statement
# patch voor juiste proj dir

git apply $DIR/basemaps.patch

# Maken mapfiles
OSM_SRID=28992 OSM_EXTENT="12000 304000 280000 620000" OSM_WMS_SRS="EPSG:4326 EPSG:900913 EPSG:28992 EPSG:3857" make
OSM_SRID=28992 OSM_EXTENT="12000 304000 280000 620000" OSM_WMS_SRS="EPSG:4326 EPSG:900913 EPSG:28992 EPSG:3857" make STYLE=nb

# Doe nu stappen in update en deploy script, behalve imposm --deploy-production-tables
mkdir /mnt/data/osm
$DIR/update.sh

# Let op: zet MAILTO=jouw@email.nl in /etc/crontab en zorg dat bv exim4 dit forwardt naar smarthost!
echo '30 170 * * * root /home/matthijsln/openbasiskaart/update-cron.sh' >> /etc/crontab

# Link directory met extra mapfiles, zie maps/*.md voor extra instructies

ln -s $DIR/maps /opt

