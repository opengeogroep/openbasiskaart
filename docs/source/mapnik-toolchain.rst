.. _mapnik-toolchain:

****************
Mapnik Toolchain
****************

Hieronder staat de "toolchain" beschreven om OSM RD Tiles te genereren en te serveren volgens
de "Mapnik Toolchain". Dit is de meest standaard OpenStreetMap methode zoals ook gebruikt voor de
tiles beschikbaar op http://openstreetmap.org, a.k.a. "The Slippy Map".

Om in RD-stelsel te werken moet nog iets speciaals gedaan worden.
Zie ook: http://justobjects.org/blog/2010/openstreetmap-tiles-for-dutch-projection-epsg28992 ;-)

Normaal gesproken wordt "mod-tile" met ``renderd`` als tileserver/generator gebruikt.
Echter dan zijn we beperkt tot TMS.
Als variant op de toolchain proberen we ``MapProxy` via ``MBTiles`` opslag.

Installaties
============

Hieronder de stappen voor installatie van de verschillende tools.

Ubuntu
------

We gaan uit van Ubuntu 12.10 64-bits. Deze moet altijd eerst uptodate gebracht worden. ::

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

Eerst afhankelijkheden installeren, vooral indien zelf compileren (deze lijst is obsolete). ::

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
    # aanmaken user "osm" met zelfde password.
    # answer yes for superuser (although this isn't strictly necessary)
    createuser osm
    psql -c "ALTER USER osm WITH PASSWORD 'osm';"
    createdb -E UTF8 -O osm postgis2_template
    psql -d postgis2_template -c "CREATE EXTENSION postgis;"
    createdb -E UTF8 -O osm gis -T postgis2_template

    # legacy.sql compat layer om problemen met Mapnik 2.0 (niet bestaande functies op te lossen)
	psql -d gis -f /usr/share/postgresql/9.1/contrib/postgis-2.0/legacy.sql

Inloggen enablen. ::

		# Edit the file /etc/postgresql/9.1/main/pg_hba.conf and replace ident by either md5 or trust,
		# depending on whether you want it to ask for a password on your own computer or not.
		# Then reload the configuration file with:

		/etc/init.d/postgresql reload


Handig is phppgadmin. Zie ook http://sql-info.de/postgresql/notes/installing-phppgadmin.html ::

	 sudo apt-get install phppgadmin

	 # Toelaten inloggen
     sudo emacs /usr/share/phppgadmin/conf/config.inc.php
     $conf['extra_login_security'] = false;

	 # dan via localhost /phppgadmin benaderen


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

Vanuit repo install. ::

       sudo apt-get install  libapache2-mod-tile

Download ook /usr/share/mapnik-osm-data/world_boundaries-spherical.tgz (50MB) en 
/usr/share/mapnik-osm-data/processed_p.tar.bz2 (500MB) en
/usr/share/mapnik-osm-data/shoreline_300.tar.bz2 (40MB). Output. ::

	Reading package lists... Done
	Building dependency tree       
	Reading state information... Done
	The following extra packages will be installed:
	  libgeotiff2 libmapnik2-2.0 librasterlite1 openstreetmap-mapnik-stylesheet-data renderd
	Suggested packages:
	  geotiff-bin gdal-bin libgeotiff-epsg
	The following NEW packages will be installed:
	  libapache2-mod-tile libgeotiff2 libmapnik2-2.0 librasterlite1 openstreetmap-mapnik-stylesheet-data renderd
	0 upgraded, 6 newly installed, 0 to remove and 0 not upgraded.
	Need to get 2,232 kB of archives.
	After this operation, 7,449 kB of additional disk space will be used.
	Do you want to continue [Y/n]? Y
	Get:1 http://archive.ubuntu.com/ubuntu/ quantal/universe libgeotiff2 amd64 1.3.0+dfsg-3 [70.3 kB]
	Get:2 http://ppa.launchpad.net/kakrueger/openstreetmap/ubuntu/ quantal/main renderd amd64 0.4-15~quantal1 [74.9 kB]
	Get:3 http://archive.ubuntu.com/ubuntu/ quantal/universe librasterlite1 amd64 1.1~svn11-2build1 [46.8 kB]
	Get:4 http://ppa.launchpad.net/kakrueger/openstreetmap/ubuntu/ quantal/main libapache2-mod-tile amd64 0.4-15~quantal1 [38.0 kB]
	Get:5 http://ppa.launchpad.net/kakrueger/openstreetmap/ubuntu/ quantal/main openstreetmap-mapnik-stylesheet-data all 0.2-r29214~quantal1 [202 kB]
	Get:6 http://archive.ubuntu.com/ubuntu/ quantal/universe libmapnik2-2.0 amd64 2.0.0+ds1-3ubuntu1 [1,800 kB]
	Fetched 2,232 kB in 1s (1,754 kB/s)       
	Preconfiguring packages ...
	Selecting previously unselected package libgeotiff2.
	(Reading database ... 74003 files and directories currently installed.)
	Unpacking libgeotiff2 (from .../libgeotiff2_1.3.0+dfsg-3_amd64.deb) ...
	Selecting previously unselected package librasterlite1:amd64.
	Unpacking librasterlite1:amd64 (from .../librasterlite1_1.1~svn11-2build1_amd64.deb) ...
	Selecting previously unselected package libmapnik2-2.0.
	Unpacking libmapnik2-2.0 (from .../libmapnik2-2.0_2.0.0+ds1-3ubuntu1_amd64.deb) ...
	Selecting previously unselected package renderd.
	Unpacking renderd (from .../renderd_0.4-15~quantal1_amd64.deb) ...
	Selecting previously unselected package libapache2-mod-tile.
	Unpacking libapache2-mod-tile (from .../libapache2-mod-tile_0.4-15~quantal1_amd64.deb) ...
	Selecting previously unselected package openstreetmap-mapnik-stylesheet-data.
	Unpacking openstreetmap-mapnik-stylesheet-data (from .../openstreetmap-mapnik-stylesheet-data_0.2-r29214~quantal1_all.deb) ...
	Processing triggers for ureadahead ...
	Setting up libgeotiff2 (1.3.0+dfsg-3) ...
	Setting up librasterlite1:amd64 (1.1~svn11-2build1) ...
	Setting up libmapnik2-2.0 (2.0.0+ds1-3ubuntu1) ...
	Setting up renderd (0.4-15~quantal1) ...
	 * Starting Mapnik rendering daemon renderd
	   ...done.
	Setting up openstreetmap-mapnik-stylesheet-data (0.2-r29214~quantal1) ...
	--2013-02-08 22:46:10--  http://tile.openstreetmap.org/world_boundaries-spherical.tgz
	Resolving tile.openstreetmap.org (tile.openstreetmap.org)... 193.63.75.98
	Connecting to tile.openstreetmap.org (tile.openstreetmap.org)|193.63.75.98|:80... connected.
	HTTP request sent, awaiting response... 200 OK
	Length: 52857349 (50M) [application/x-gzip]
	Saving to: `/usr/share/mapnik-osm-data/world_boundaries-spherical.tgz'
	
	100%[===============================================================================================================================================>] 52,857,349   689K/s   in 51s     
	
	2013-02-08 22:47:01 (1007 KB/s) - `/usr/share/mapnik-osm-data/world_boundaries-spherical.tgz' saved [52857349/52857349]
	
	--2013-02-08 22:47:01--  http://tile.openstreetmap.org/processed_p.tar.bz2
	Resolving tile.openstreetmap.org (tile.openstreetmap.org)... 193.63.75.98
	Connecting to tile.openstreetmap.org (tile.openstreetmap.org)|193.63.75.98|:80... connected.
	HTTP request sent, awaiting response... 200 OK
	Length: 409468857 (390M) [application/x-bzip2]
	Saving to: `/usr/share/mapnik-osm-data/processed_p.tar.bz2'
	100%[===============================================================================================================================================>] 409,468,857 1.65M/s   in 3m 22s  
	
	2013-02-08 22:50:24 (1.93 MB/s) - `/usr/share/mapnik-osm-data/processed_p.tar.bz2' saved [409468857/409468857]
	
	--2013-02-08 22:50:24--  http://tile.openstreetmap.org/shoreline_300.tar.bz2
	Resolving tile.openstreetmap.org (tile.openstreetmap.org)... 193.63.75.98
	Connecting to tile.openstreetmap.org (tile.openstreetmap.org)|193.63.75.98|:80... connected.
	HTTP request sent, awaiting response... 200 OK
	Length: 43867136 (42M) [application/x-bzip2]
	Saving to: `/usr/share/mapnik-osm-data/shoreline_300.tar.bz2'
	
	100%[===============================================================================================================================================>] 43,867,136  1.12M/s   in 43s     
	
	2013-02-08 22:51:07 (997 KB/s) - `/usr/share/mapnik-osm-data/shoreline_300.tar.bz2' saved [43867136/43867136]
	
	--2013-02-08 22:51:07--  http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places.zip
	Resolving www.naturalearthdata.com (www.naturalearthdata.com)... 66.147.242.194
	Connecting to www.naturalearthdata.com (www.naturalearthdata.com)|66.147.242.194|:80... connected.
	HTTP request sent, awaiting response... 302 Moved Temporarily
	Location: http://www.nacis.org/naturalearth/10m/cultural/ne_10m_populated_places.zip [following]
	--2013-02-08 22:51:08--  http://www.nacis.org/naturalearth/10m/cultural/ne_10m_populated_places.zip
	Resolving www.nacis.org (www.nacis.org)... 146.201.97.163
	Connecting to www.nacis.org (www.nacis.org)|146.201.97.163|:80... connected.
	HTTP request sent, awaiting response... 200 OK
	Length: 1578296 (1.5M) [application/x-zip-compressed]
	Saving to: `/usr/share/mapnik-osm-data/ne_10m_populated_places.zip'
	
	100%[===============================================================================================================================================>] 1,578,296    449K/s   in 4.2s    
	
	2013-02-08 22:51:12 (367 KB/s) - `/usr/share/mapnik-osm-data/ne_10m_populated_places.zip' saved [1578296/1578296]
	
	--2013-02-08 22:51:12--  http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_boundary_lines_land.zip
	Resolving www.naturalearthdata.com (www.naturalearthdata.com)... 66.147.242.194
	Connecting to www.naturalearthdata.com (www.naturalearthdata.com)|66.147.242.194|:80... connected.
	HTTP request sent, awaiting response... 302 Moved Temporarily
	Location: http://www.nacis.org/naturalearth/110m/cultural/ne_110m_admin_0_boundary_lines_land.zip [following]
	--2013-02-08 22:51:13--  http://www.nacis.org/naturalearth/110m/cultural/ne_110m_admin_0_boundary_lines_land.zip
	Resolving www.nacis.org (www.nacis.org)... 146.201.97.163
	Connecting to www.nacis.org (www.nacis.org)|146.201.97.163|:80... connected.
	HTTP request sent, awaiting response... 200 OK
	Length: 44731 (44K) [application/x-zip-compressed]
	Saving to: `/usr/share/mapnik-osm-data/ne_110m_admin_0_boundary_lines_land.zip'
	
	100%[===============================================================================================================================================>] 44,731      55.3K/s   in 0.8s    
	
	2013-02-08 22:51:14 (55.3 KB/s) - `/usr/share/mapnik-osm-data/ne_110m_admin_0_boundary_lines_land.zip' saved [44731/44731]
	
	world_boundaries/
	world_boundaries/places.shx
	world_boundaries/world_boundaries_m.index
	world_boundaries/world_bnd_m.shx
	world_boundaries/builtup_area.shx
	world_boundaries/world_bnd_m.dbf
	world_boundaries/builtup_area.prj
	world_boundaries/places.shp
	world_boundaries/world_boundaries_m.shx
	world_boundaries/world_boundaries_m.shp
	world_boundaries/places.dbf
	world_boundaries/places.prj
	world_boundaries/builtup_area.dbf
	world_boundaries/world_bnd_m.shp
	world_boundaries/world_bnd_m.prj
	world_boundaries/world_boundaries_m.dbf
	world_boundaries/builtup_area.shp
	world_boundaries/world_boundaries_m.prj
	world_boundaries/world_bnd_m.index
	world_boundaries/builtup_area.index
	processed_p.dbf
	processed_p.index
	processed_p.shp
	processed_p.shx
	shoreline_300.dbf
	shoreline_300.index
	shoreline_300.shp
	shoreline_300.shx
	Archive:  /usr/share/mapnik-osm-data/ne_10m_populated_places.zip
	  inflating: /usr/share/mapnik-osm-data/world_boundaries/ne_10m_populated_places.README.html  
	 extracting: /usr/share/mapnik-osm-data/world_boundaries/ne_10m_populated_places.VERSION.txt  
	  inflating: /usr/share/mapnik-osm-data/world_boundaries/ne_10m_populated_places.dbf  
	  inflating: /usr/share/mapnik-osm-data/world_boundaries/ne_10m_populated_places.prj  
	  inflating: /usr/share/mapnik-osm-data/world_boundaries/ne_10m_populated_places.shp  
	  inflating: /usr/share/mapnik-osm-data/world_boundaries/ne_10m_populated_places.shx  
	Archive:  /usr/share/mapnik-osm-data/ne_110m_admin_0_boundary_lines_land.zip
	  inflating: /usr/share/mapnik-osm-data/world_boundaries/ne_110m_admin_0_boundary_lines_land.README.html  
	 extracting: /usr/share/mapnik-osm-data/world_boundaries/ne_110m_admin_0_boundary_lines_land.VERSION.txt  
	  inflating: /usr/share/mapnik-osm-data/world_boundaries/ne_110m_admin_0_boundary_lines_land.dbf  
	  inflating: /usr/share/mapnik-osm-data/world_boundaries/ne_110m_admin_0_boundary_lines_land.prj  
	  inflating: /usr/share/mapnik-osm-data/world_boundaries/ne_110m_admin_0_boundary_lines_land.shp  
	  inflating: /usr/share/mapnik-osm-data/world_boundaries/ne_110m_admin_0_boundary_lines_land.shx  
	Processing triggers for ureadahead ...
	Setting up libapache2-mod-tile (0.4-15~quantal1) ...
	Enabling module tile.
	To activate the new configuration, you need to run:
	  service apache2 restart
	Enabling site tileserver_site.
	To activate the new configuration, you need to run:
	  service apache2 reload
	Site default disabled.
	To activate the new configuration, you need to run:
	  service apache2 reload
	 * Restarting web server apache2
	[Fri Feb 08 22:52:40 2013] [notice] Committing tile config default
	[Fri Feb 08 22:52:40 2013] [notice] Loading tile config default at /osm/ for zooms 0 - 18 from tile directory /var/lib/mod_tile with extension .png and mime type image/png
	apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1 for ServerName
	 ... waiting [Fri Feb 08 22:52:41 2013] [notice] Committing tile config default
	[Fri Feb 08 22:52:41 2013] [notice] Loading tile config default at /osm/ for zooms 0 - 18 from tile directory /var/lib/mod_tile with extension .png and mime type image/png
	apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1 for ServerName
	   ...done.
	Processing triggers for libc-bin ...
	ldconfig deferred processing now taking place


Toch even checken want hier wordt ook Mapnik installed! Bovenstaande installeert/activeert mod_tile en renderd.

NB bovenstaande wordt dus MBTiles+MapProxy!!

Data
====

Het laden van de data. Gebied Amsterdam. Zie http://metro.teczno.com/#amsterdam

.. figure:: _static/amsterdam-osm-extent.jpg
   :align: center

   *Figuur MT-1 - Amsterdam Extent (bron: http://metro.teczno.com/#amsterdam)*

Data ophalen. ::

	mkdir /opt/openbasiskaart/data

	# PBF download (53 MB)
	wget http://osm-metro-extracts.s3.amazonaws.com/amsterdam.osm.pbf

	# Coastline A'dam area download (53 MB)
	wget http://osm-metro-extracts.s3.amazonaws.com/amsterdam.coastline.zip

Data laden in PostgreSQL.  ::

	cd /opt/openbasiskaart/data

	# Op locale VirtualBox VM met weinig geheugen
	# met "--cache-strategy sparse"
	osm2pgsql -W -U osm -d gis --slim --cache-strategy sparse  amsterdam.osm.pbf

	# duurt plm 900 sec op VM

Services
========

Configureren Renderd/Mapnik/mod_tile. ::

	# Maak kopie default mapnik config
	mkdir /opt/openbasiskaart/mapnik
	cp -r  /etc/mapnik-osm-data /opt/openbasiskaart/mapnik/default
	cd /opt/openbasiskaart/mapnik/default

	# zet user/password naar osm/osm in
	e inc/datasource-settings.xml.inc

	<Parameter name="type">postgis</Parameter>
	<Parameter name="password">osm</Parameter>
	<Parameter name="host">localhost</Parameter>
	<Parameter name="user">osm</Parameter>
	<Parameter name="dbname">gis</Parameter>
	<!-- this should be 'false' if you are manually providing the 'extent' -->
	<Parameter name="estimate_extent">false</Parameter>
	<!-- manually provided extent in epsg 900913 for whole globe -->
	<!-- providing this speeds up Mapnik database queries -->
	<!-- <Parameter name="extent">4.88,52.36,4.90,52.38</Parameter> -->
	<Parameter name="extent">543239.115,6865481.657,545465.505,6869128.129</Parameter>

	# herstarten en log volgen renderd
	tail -f /var/log/syslog |grep renderd &
	/etc/init.d/renderd restart

Notes:

* Mapnik 2.0 met PosGIS 2.0: legacy.sql laden in PostGIS DB
    - ``psql -d gis -f /usr/share/postgresql/9.1/contrib/postgis-2.0/legacy.sql``
* extent
	- moet in EPSG:900913
	- extent gezet op klein stukje A'dam C voor testen
* tiles verwijderen/opschonen
    - ``rm -rf /var/lib/mod_tile/default``
    - ``touch /var/lib/mod_tile/planet-import-complete``
* herstarten renderd: ``/etc/init.d/renderd restart``
* PostgreSQL debug output zetten: ``/etc/postgresql/9.1/main/postgresql.conf``, zet ``client_min_messages = log``
* volgen renderd logfile: ``tail -f /var/log/syslog |grep renderd &``
* volgen postgresql log: ``tail -f /var/log/postgresql/postgresql-9.1-main.log &``

Demo
====

Een demo app staat onder ``/var/www/osm/slippymap.html``. Hier HTML aanpassen om centrum op Amsterdam te zetten.
Evt port zetten indien port forwarding naar local VM (8090 bijv). Dan zetten. ::

	var newLayer = new OpenLayers.Layer.OSM("Local Tiles",
	          "http://localhost:8090/osm/${z}/${x}/${y}.png", {numZoomLevels: 19});

Het resultaat met wat logging info hieronder.

.. figure:: _static/renderd-working2.jpg
   :align: center

   *Figuur MT-2 - Amsterdam-C Extent met renderd+PostgreSQL logging*







