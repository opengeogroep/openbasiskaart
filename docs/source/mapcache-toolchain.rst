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

    ??


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

