Installatieinstructies Openbasiskaart
=====================================


```bash
git clone https://github.com/opengeogroep/openbasiskaart.git
cd openbasiskaart

# Installeren packages (lijst voor Ubunbtu 16.04)
apt-get install realpath xmlstarlet curl ack-grep libdatetime-format-http-perl postgresql postgis libapache2-mod-fcgid libapache2-mod-mapcache mapcache-tools apache2 cgi-mapserver mapserver-bin mapcache-tools mapcache-cgi apache2 shapelib python-pip build-essential python-dev protobuf-compiler libprotobuf-dev libtokyocabinet-dev python-psycopg2 libgeos-c1v5 python-yaml

DIR=`pwd`

# Kopie van GitHub repo voor website
git clone https://github.com/opengeogroep/openbasiskaart.git /var/www/openbasiskaart
chown -R www-data:www-data /var/www/openbasiskaart

# Kopieer github update hook (zie settings openbasiskaart GitHub repo)
cp $DIR/github-update-site-webhook.sh /usr/lib/cgi-bin

# Link configuratiebestanden
ln -s $DIR/mapcache.xml /etc/apache2/mapcache.xml
ln -s $DIR/apache/openbasiskaart.conf /etc/apache2/sites-available/openbasiskaart.conf
ln -s $DIR/apache/openbasiskaart-ssl.conf /etc/apache2/sites-available/openbasiskaart-ssl.conf
ln -s $DIR/apache/openbasiskaart.inc /etc/apache2/openbasiskaart.inc
mkdir /mnt/data/mapcache
ln -s $DIR/mapcache.xml /mnt/data/mapcache
chown www-data:www-data /mnt/data/mapcache

# ServerAlias is globaal ingesteld in openbasiskaart.conf (om warning bij herstart te vermijden), 
# daarom moet 000-default moet gedisabled worden
a2dissite 000-default
a2ensite openbasiskaart openbasiskaart-ssl
a2enmod headers cgid ssl
service apache2 restart

su - postgres -c 'createuser osm'
su - postgres -c "psql -c \"alter role osm password 'osm'\""
su - postgres -c 'createdb --owner=osm osm'
su - postgres -c "psql osm -c 'create extension postgis'"

pip install  https://github.com/omniscale/imposm/tarball/master
pip install https://github.com/omniscale/imposm/tarball/master 

cd /opt
git clone https://github.com/mapserver/basemaps.git 
make data
git apply $DIR/basemaps.patch
make
make STYLE=nb

# Doe nu stappen in update en deploy script, behalve imposm --deploy-production-tables

