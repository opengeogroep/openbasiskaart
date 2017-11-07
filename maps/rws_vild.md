```sh
wget --recursive --no-parent  -nH --level=1 --cut-dirs=7 -R "index.html*" -N "https://www.rijkswaterstaat.nl/apps/geoservices/geodata/dmc/vild/geogegevens/shapefile/Vild512a_Rd_definitief/"

createdb rws_vild
psql rws_vild -c 'create extension postgis'

pgdbf -s iso-8859-1 Vild512a_Rd_definitief/TopicRef.dbf > topicref.sql
pgdbf -s iso-8859-1 Vild512a_Rd_definitief/vild512a_v2.dbf > vild512a_v2.sql

(echo 'set session authorization osm; '; cat topicref.sql) | psql rws_vild
(echo 'set session authorization osm; '; cat vild512a_v2.sql) | psql rws_vild

(echo 'set session authorization osm; '; shp2pgsql -s 28992 -g geom -D -i -I -t 2D tmc_area.shp) | psql rws_vild
(echo 'set session authorization osm; '; shp2pgsql -s 28992 -g geom -D -i -I -t 2D tmc_line.shp) | psql rws_vild
(echo 'set session authorization osm; '; shp2pgsql -s 28992 -g geom -D -i -I -t 2D tmcpoint.shp) | psql rws_vild
```

