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



Postgresql/PostGIS
------------------
On Ubuntu there are pre-packaged versions of both postgis and postgresql, so
these can simply be installed via the ubuntu package manager. ::

    sudo apt-get install postgresql-9.1-postgis postgresql-contrib postgresql-server-dev-9.1

    sudo -u postgres -i
    createuser osm # answer yes for superuser (although this isn't strictly necessary)
    createdb -E UTF8 -O osm gis

    psql -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql -d gis
    psql -d gis -c "ALTER TABLE geometry_columns OWNER TO osm; ALTER TABLE  spatial_ref_sys OWNER TO osm;"

    exit

Imposm
------

Imposm wordt gebruikt voor inlezen OSM Planet dump in Postgres...


Mapserver
---------

Mapcache
--------

Mapcache_seed
-------------
De nieuwste versie is nodig, omdat er een bugje in de oude zat.

Sqlite3
-------

Data
====


Data downloaden
Data inladen met imposm

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

