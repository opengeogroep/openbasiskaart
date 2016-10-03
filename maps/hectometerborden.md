Mapfile Hectometerborden
========================

# 0. Database setup (eenmalig)

```createdb nwb --owner=osm
psql nwb -c 'create extension postgis;'
```

# 1. Downloaden gegevens (maandelijks)

Download het laatste ZIP-bestand van:

http://www.rijkswaterstaat.nl/apps/geoservices/geodata/dmc/nwb-wegen/geogegevens/shapefile/Nederland_totaal/

# 2. Uitpakken

`unzip 01-10-2016.zip`

# 3. Inladen in PostgreSQL

Vervang hieronder de datum met die van het laatst gedownloadde NWB:

```psql nwb -c "create schema nwb20161001 authorization osm;"
(echo 'set session authorization osm;'; shp2pgsql -s 28992 -g geom -D -i -I -S -t 2D 01-10-2016/Hectopunten/Hectopunten.shp  nwb20161001.hectopunten) | psql nwb
(echo 'set session authorization osm;'; shp2pgsql -s 28992 -g geom -D -i -I -S -t 2D 01-10-2016/Wegvakken/Wegvakken.shp  nwb20161001.wegvakken) | psql nwb
psql nwb -c "create index idx_wegvakken_wvk_id ON nwb20161001.wegvakken (wvk_id);"
```

# 4. Aanmaken view

Pas in `hectometerborden.sql` de schemanaam aan om te wijzen naar de net ingeladen NWB versie en voer deze uit. Drop nu het oude NWB
schema na controleren of de mapfile goed werkt. Verwijder het ZIP bestand en uitgepakte bestanden.

(echo 'set session authorization osm;'; cat hectometerborden.sql) | psql nwb
