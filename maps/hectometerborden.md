Mapfile Hectometerborden
========================

# 0. Database setup (eenmalig)

```bash
createdb nwb --owner=osm
psql nwb -c 'create extension postgis;'
```

# 1. Gegevens inladen (maandelijks)

Importeer de hectopunten CSV van Falck en maak hier een shapefile van.

Vervang hieronder de datum met die van de huidige maand:

```bash
export DATUM=201710
psql nwb_falck -c "create schema nwb_$DATUM authorization osm;"
(echo 'set session authorization osm;'; shp2pgsql -s 28992 -g geom -D -i -I -S -t 2D hectometerborden.shp nwb_$DATUM.hectopunten) | psql nwb_falck
```

# 2. Aanmaken view

Pas in `hectometerborden.sql` de schemanaam aan om te wijzen naar de net ingeladen NWB versie en voer deze uit. Drop nu het oude NWB schema na controleren of de mapfile goed werkt. 

```bash
(echo 'set session authorization osm;'; cat hectometerborden.sql) | psql nwb
```
