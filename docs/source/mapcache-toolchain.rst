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

	sudo apt-get install mapcache-cgi mapcache-tools

Mapcache_seed
-------------
De nieuwste versie is nodig, omdat er een bugje in de oude zat. TODO kijken of dit nog nodig is

Sqlite3
-------
Voor mbtiles nodig. ::

	sudo apt-get install sqlite3

Data
====

Data downloaden 
--------------- ::
	mkdir /opt/openbasiskaart/data

	# PBF download (53 MB)
	wget http://osm-metro-extracts.s3.amazonaws.com/amsterdam.osm.pbf

Data inladen
------------

Lees de data (voorbewerking van imposm) ::
	sudo imposm --read amsterdam.osm.pbf

Service
=======
Maak de service in de mapfile

Tiling
======
Maak mbtiles cache ::

	sqlite3 osmcache.mbtiles

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


Setup mapcache
mapcache.xml
Let op:
Expiration data

Seeding
=======
	mapcache_seed -c mapcache-osm.xml -t osm -g rd

