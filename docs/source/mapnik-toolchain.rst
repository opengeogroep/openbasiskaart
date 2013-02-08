.. _mapnik-toolchain:

****************
Mapnik Toolchain
****************

Hieronder staat de "toolchain" beschreven om OSM RD Tiles te genereren en te serveren volgens
de "Mapnik Toolchain". Dit is de meest standaard OpenStreetMap methode zoals ook gebruikt voor de
tiles beschikbaar op http://openstreetmap.org, a.k.a. "The Slippy Map".

Om in RD-stelsel te werken moet nog iets speciaals gedaan worden.
Zie ook: http://justobjects.org/blog/2010/openstreetmap-tiles-for-dutch-projection-epsg28992 ;-)

Normaal gesproken wordt "mod-tile" met renderd als tileserver/generator gebruikt.
Echter dan zijn we beperkt tot TMS.
Als variant op de toolchain proberen we MapProxy via MBTiles.

Installaties
============

Hieronder de stappen voor installatie van de verschillende tools.

Ubuntu
------

We gaan uit van Ubuntu 12.10 64bits. Deze moet altijd eerst uptodate gebracht worden. ::

	sudo apt-get update
	sudo apt-get upgrade

Repositories
------------

Ubuntu bevat vaak niet laatste versies benodigde packages. Door repositories aan
"Apt" toe te voegen kan wel via standaard packages recente versies geinstalleerd worden.
Allereerst evt tool om repo's toe te voegen (hoeft niet op Ubuntu 12.10). ::

	# install the command add-apt-repository if the command can't be found.
	sudo apt-get install software-properties-common

Dan Kai Krueger's repo (https://launchpad.net/~kakrueger/+archive/openstreetmap Osm2pgsql, Imposm, Osmosis, Mapnik styles etc). ::

	# to add the PPA and update your packaging system.
	sudo add-apt-repository ppa:kakrueger/openstreetmap
	sudo apt-get update

Altijd UbuntuGIS toevoegen https://wiki.ubuntu.com/UbuntuGIS ! ::

	# to add the UbuntuGIS PPA and update your packaging system.
        sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
	sudo apt-get update

Check of de repo's goed zijn toegevoegd. ::

       ls /etc/apt/sources.list.d
       # geeft
       kakrueger-openstreetmap-quantal.list  kakrueger-openstreetmap-quantal.list.save  ubuntugis-ubuntugis-unstable-quantal.list

Afhankelijkheden
----------------

Eerst afhankelijkheden installeren, vooral indien zelf compileren. ::

     sudo apt-get install subversion git-core tar unzip wget bzip2 build-essential autoconf libtool
     libxml2-dev libgeos-dev libpq-dev libbz2-dev proj munin-node munin
     libprotobuf-c0-dev protobuf-c-compiler libfreetype6-dev libpng12-dev
     libtiff4-dev libicu-dev  libgdal-dev libcairo-dev
     libcairomm-1.0-dev apache2 libagg-dev apt-show-versions


Proj: 4.8.0-3~quantal1

GDAL: 1.9.2-2~quantal6

Geos: 3.3.3-1.1

Postgresql/PostGIS
------------------
Belangrijk is om package "postgis" te installeren. Dan komt alles, bijv. Postgres 9.1, mee. ::

    sudo apt-get install postgis postgresql-contrib postgresql-server-dev-9.1

Check of PostGIS v2 is installed. ::

    apt-show-versions | grep postgis
    # moet geven
    postgis/quantal uptodate 2.0.1-2~quantal3
    postgresql-9.1-postgis/quantal uptodate 2.0.1-2~quantal3

Template database aanmaken. Nieuwe manier voor PostGIS 2.0 met EXTENSIONS (ipv PostGIS sql laden)
zie http://postgis.net/docs/manual-2.0/postgis_installation.html#create_new_db_extensions

    sudo -u postgres -i
    createuser osm # answer yes for superuser (although this isn't strictly necessary)
    createdb -E UTF8 -O osm postgis2_template
    psql -d postgis2_template -c "CREATE EXTENSION postgis;"
    exit


OSM2PGSQL
---------

OSM2pgsql wordt gebruikt voor inlezen OSM Planet dump in Postgres.
Zie ook http://wiki.openstreetmap.org/wiki/Osm2pgsql ::

    # install the osm2pgsql package.
    sudo apt-get install osm2pgsql

Installeert: osm2pgsql (0.81.0-1~quantal3). NB Dit is de juiste versie voor 64-bit ID ondersteuning.
Zie http://web.archiveorange.com/archive/v/wQWIb2eq6T9IKbr4XkWx.

Mapnik
------

Mapnik is voor generatie van tiles. Via eigen repo installeren. Zelf compileren is verleden tijd! Zie ook 
https://github.com/mapnik/mapnik/wiki/UbuntuInstallation en de packages: 
https://launchpad.net/~mapnik/+archive/v2.1.0/+packages ::

      sudo add-apt-repository ppa:mapnik/v2.1.0
      sudo apt-get update
      sudo apt-get install libmapnik mapnik-utils python-mapnik

Check installatie (libmapnik_2.1.0-ubuntu1~quantal2_amd64.deb). ::
  
      python
      Python 2.7.3 (default, Sep 26 2012, 21:51:14) 
      [GCC 4.7.2] on linux2
      Type "help", "copyright", "credits" or "license" for more information.
      >>> import mapnik
      >>> 


mod_tile+renderd
----------------

NB wordt dus MBTiles+MapProxy!!
Install mod_tile and renderd (alles met sudo)

Compile the mod_tile source code (moet altijd eerst mapnik!). ::

    sudo mkdir /opt/mod_tile
    cd /opt/mod_tile
    sudo svn co http://svn.openstreetmap.org/applications/utils/mod_tile svn
    cd svn
	sudo ./autogen.sh
	sudo ./configure
	sudo make
	sudo make install
	sudo make install-mod_tile
	sudo ldconfig


