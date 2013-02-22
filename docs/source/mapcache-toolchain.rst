.. _mapcache-toolchain:

******************
Mapcache Toolchain
******************

Hieronder staat de "toolchain" beschreven om OSM RD Tiles te genereren en te serveren volgens
de "MapCache Toolchain". Dit is een toolchain op basis van Imposm, MapServer en MapCache.


Installaties
============

Hieronder de stappen voor installatie van de verschillende tools.

Afhankelijkheden
----------------

Eerst afhankelijkheden installeren ::

UbuntuGIS PPA
-------------

https://wiki.ubuntu.com/UbuntuGIS ! ::

	# to add the UbuntuGIS PPA and update your packaging system.
	sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
	sudo apt-get update

Installeer apache ::

	sudo apt-get install apache2

Installeer git ::

	sudo apt-get install git


Postgresql/PostGIS
------------------
On Ubuntu there are pre-packaged versions of both postgis and postgresql, so
these can simply be installed via the ubuntu package manager. ::

	sudo apt-get install postgis
	sudo apt-get install pgadmin3

	sudo -u postgres -i
	# aanmaken user "osm" met zelfde password.
	# answer yes for superuser (although this isn't strictly necessary)
	createuser osm
	psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
	createdb -E UTF8 -O postgres postgis2_template
	psql -d postgis2_template -c "CREATE EXTENSION postgis;"

	# Aanmaken DB met PostGIS template
	createdb -E UTF8 -O osm gis -T postgis2_template

	# Zorg voor data schema, om postgis dingen te scheiden
	psql osm
	create schema data authorization osm;
	alter database osm set search_path = data, public
	grant alll on spatial_ref_sys to public;

    exit

Imposm
------

Imposm wordt gebruikt voor inlezen OSM Planet dump in Postgres.
Zie ook http://imposm.org/docs/imposm/latest/install.html
Install requirements ::
	sudo apt-get install build-essential python-dev protobuf-compiler \
                      libprotobuf-dev libtokyocabinet-dev python-psycopg2 \
                      libgeos-c1
	sudo apt-get install python-pip
	sudo pip install imposm

Mapserver
---------
De mapserver om de plaatjes te renderen ::

	sudo apt-get install cgi-mapserver mapserver-bin

Test in browser of mapserver het doet ::

	http://localhost/cgi-bin/mapserv

Als het goed is staat er nu iets als "No query information to decode. QUERY STRING is set, but empty."



Mapcache
--------
Installeer de tiling applicatie. Dit is een apache module ::

	sudo apt-get install libmapcache mapcache-cgi mapcache-tools libapache2-mod-mapcache
	mkdir ~/osm-demo/mapcache/cache
	sudo chown www-data ~/osm-demo/mapcache/cache/


Sqlite3
-------
Voor mbtiles nodig. ::

	sudo apt-get install sqlite3

Data
====

Data downloaden 
--------------- 
::

	mkdir /opt/openbasiskaart/data

	# PBF download (53 MB)
	wget http://osm-metro-extracts.s3.amazonaws.com/amsterdam.osm.pbf

Data inladen
------------

Lees de data (voorbewerking van imposm) ::

	sudo imposm --proj=EPSG:28992 --read amsterdam.osm.pbf

Schrijf de data naar postgis ::

	sudo imposm --write --database osm --proj=EPSG:28992 --host localhost --user osm --port 5432

Check of de data goed is geschreven (in relatie tot de herprojectie) ::

	select distinct(st_srid(geometry)) from osm_new aeroways;

Als het goed is komt hier alleen 28992 uit. Zo niet, dan moet je iets herstellen zodat dit wel het geval wordt!

Service
=======
Maak de service in de mapfile

Mapserver utils
---------------
	
Zie ook http://trac.osgeo.org/mapserver/wiki/RenderingOsmDataUbuntu#Installmapserver-utilsmapfilegenerator
Download mapserverutils ::

	git clone https://github.com/mapserver/basemaps.git
	cd basemaps
	gedit osmbase.map


	-------------------8<------------------------
	  WEB
	...
	    IMAGEPATH "/tmp/ms_tmp/"
	    IMAGEURL "/ms_tmp/"
	 END
	...
	-------------------->8-----------------------

	  vi Makefile
	-------------------8<------------------------
	OSM_SRID=28992
	OSM_UNITS=meters
	OSM_EXTENT=12000 304000 280000 620000
	...
	STYLE=default
	...
	OSM_WMS_SRS=EPSG:28992
	-------------------->8-----------------------

	mkdir /tmp/ms_tmp
	chmod 777 /tmp/ms_tmp

    Execute the mapserver-utils makefile to generate the mapfile. Note that the first time you run 'make' several large files will be downloaded (country boundaries, etc.). This will happen only the first time.

      cd mapserver-utils-svn
	cd data 
	gedit Makefile

	#Verander bij boundary lines de link naar >http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_boundary_lines_land.zip<\
	# Verander bij unzip van boundary lines de parameter die aan unzip wordt meegegeven naar >ne_10m_admin_0_boundary_lines_land.zip<
	make
	cd ..
	make

Comment de regel uit waarop staat ::

	#CONFIG "PROJ_LIB" "/home/<USERNAME>/<path_to_mapserverutil>"

Verzeker je ervan dan bij de srs-en 28992 staat ::

	"wms_srs" "EPSG:28992 EPSG:4326 EPSG:3857 EPSG:2154 EPSG:310642901 EPSG:4171 EPSG:310024802 EPSG:310915814 EPSG:310486805 EPSG:310702807 EPSG:310700806 EPSG:310547809 EPSG:310706808 EPSG:310642810 EPSG:310642801 EPSG:310642812 EPSG:310032811 EPSG:310642813 EPSG:2986 "

Maak verbinding naar de osm database en voer het volgende script uit ::

	
	set session authorization osm;
	-- DROP VIEW osm_new_waterways_gen0_view;

	CREATE OR REPLACE VIEW osm_new_waterways_gen0_view AS 
	 SELECT osm_new_waterways.id, osm_new_waterways.osm_id, osm_new_waterways.name, osm_new_waterways.type, st_simplifypreservetopology(osm_new_waterways.geometry, 200::double precision) AS geometry
	   FROM osm_new_waterways;

	ALTER TABLE osm_new_waterways_gen0_view
	  OWNER TO osm;

	-- View: osm_new_waterways_gen1_view

	-- DROP VIEW osm_new_waterways_gen1_view;

	CREATE OR REPLACE VIEW osm_new_waterways_gen1_view AS 
	 SELECT osm_new_waterways.id, osm_new_waterways.osm_id, osm_new_waterways.name, osm_new_waterways.type, st_simplifypreservetopology(osm_new_waterways.geometry, 50::double precision) AS geometry
	   FROM osm_new_waterways;

	ALTER TABLE osm_new_waterways_gen1_view
	  OWNER TO osm;


	CREATE TABLE osm_new_waterways_gen1 AS
	  SELECT * FROM osm_new_waterways_gen1_view;


	CREATE TABLE osm_new_waterways_gen0 AS
	  SELECT * FROM osm_new_waterways_gen0_view;


Test de mapfile door naar ::

	
	http://yourserver.tld/cgi-bin/mapserv?map=/path/to/osm-demo/mapserver-utils-svn/osm-outlined,google.map&mode=browse&template=openlayers&layers=all

Te gaan. Als er een pagina met openlayers en de kaart verschijnt, is het goed gegaan.

Kopieër de mapfile, fonts, font.lst en de datamap naar de gewenste plek: /opt/openbasiskaart/maps

	

Tiling
======

Maak het cache pad een geef www-data schrijfrechten ::

	mkdir /opt/openbasiskaart/cache
	sudo chown www-data /opt/openbasiskaart/cache/
	cd /opt/openbasiskaart/cache

Maak mbtiles cache ::

	sudo sqlite3 osmcache.mbtiles

Voer uit ::

	create table if not exists images(
	  tile_id text,
	  tile_data blob,
	  primary key(tile_id));
	create table if not exists map (
	  zoom_level integer,
	  tile_column integer,
	  tile_row integer,
	  tile_id text,
	  foreign key(tile_id) references images(tile_id),
	  primary key(tile_row,tile_column,zoom_level));
	create table if not exists metadata(
	  name text,
	  value text); -- not used or populated yet
	create view if not exists tiles
	  as select
	     map.zoom_level as zoom_level,
	     map.tile_column as tile_column,
	     map.tile_row as tile_row,
	     images.tile_data as tile_data
	  from map
	     join images on images.tile_id = map.tile_id;
	.exit

Geef www-date rechten op de cache ::

	sudo chown www-data osmcache.mbtiles
	


Setup mapcache
--------------

De configuratie voor mapcache :: 

	<?xml version="1.0" encoding="UTF-8"?>

	<!-- see the accompanying mapcache.xml.sample for a fully commented configuration file -->

	<mapcache>
		<cache name="mbtiles" type="mbtiles">
		   <dbfile>/opt/openbasiskaart/cache/osmcache.mbtiles</dbfile>
		</cache>

		<source name="osm" type="wms">
			<getmap>
			 <params>
			    <FORMAT>image/png</FORMAT>
			    <LAYERS>default</LAYERS>
			    <SRS>epsg:28992</SRS>
			 </params>
			</getmap>

			<http>
			 <url>http://localhost/cgi-bin/mapserv?map=/opt/openbasiskaart/maps/osm-default.map</url>
			</http>
		</source>
		<grid name="rd">
			<metadata>
			 <title>Rijksdriehoek-stelsel</title>
			</metadata>
			<extent>12000,304000,280000,620000</extent>
			<srs>epsg:28992</srs>
			<resolutions>3440.64 1720.32 860.16 430.08 215.04 107.52 53.76 26.88 13.44 6.72 3.36 1.68 0.84 0.42 0.21</resolutions>
			<units>m</units>
			<size>256 256</size>
		</grid>
		<tileset name="osm">
			<metadata>
			 <title>OSM MapServer served map</title>
			 <abstract>see http://trac.osgeo.org/mapserver/wiki/RenderingOsmDataUbuntu</abstract>
			</metadata>
			<source>osm</source>
			<cache>mbtiles</cache>
			<format>PNG</format>
			<grid>rd</grid>
		</tileset>


		<default_format>JPEG</default_format>

		<service type="wms" enabled="true">
			<full_wms>assemble</full_wms>
			<resample_mode>bilinear</resample_mode>
			<format>JPEG</format>
			<maxsize>4096</maxsize>
		</service>
		<service type="wmts" enabled="true"/>
		<service type="tms" enabled="true"/>
		<service type="kml" enabled="true"/>
		<service type="gmaps" enabled="true"/>
		<service type="ve" enabled="true"/>
		<service type="demo" enabled="true"/>
		<errors>log</errors>
		<lock_dir>/tmp</lock_dir>
	</mapcache>

Sla dit bestand op en zet het in /opt/openbasiskaart/cache.

Seeding
=======

seed de tiles ::

	mapcache_seed -c mapcache-osm.xml -t osm -g rd -z 0,15

