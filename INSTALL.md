Installatieinstructies Openbasiskaart
=====================================

Zoveel mogelijke automatische installatie en setup met cloud-init.

Lokaal met bijvoorbeeld Multipass:

```bash
multipass launch -c 12 -d 20G -m 8G -n obk --mount .:/opt/openbasiskaart --cloud-init cloud-init.yaml 22.04
```

Hetzner:

Let op: als je geen `--ssh-key` argument gebruikt, wordt er een root account gemaakt met verlopen wachtwoord. Dan kan
door cloud-init niet postgresql worden geinstalleerd omdat geen postgres user account kan worden aangemaakt. Eventueel
kan met cloud-init het wachtwoord op niet-verlopen worden gezet.

```
hcloud server create \
    --type cx11 \
    --image ubuntu-22.04 \
    --name openbasiskaart-v3 \
    --ssh-key matthijsln@b3p-matthijs \
    --user-data-from-file cloud-init.yaml
```

Log hierna in op de server en controleer met `cloud-init status --long` of alles geinstalleerd is en check
`/var/log/cloud-init-output.log`.

Voer daarna uit:
```bash
cd /opt/openbasiskaart
sudo wget https://download.geofabrik.de/europe/netherlands-latest.osm.pbf
sudo ./imposm-import.sh
```

TODO (oud)
==========
```
# Let op! Vanwege schijnbare memory leak in mod_mapcache in /etc/apache2/mods-enabled/mpm_event.conf:
# MaxConnectionsPerChild   2000
```

```
# patch voor nb stijl
# patch voor EXTENT bij elke LAYER, omdat anders GetCap ST_Extent() doet met deze warnings:
# landuse4/landuse5: WARNING: Optional Ex_GeographicBoundingBox could not be established for this layer.  Consider setting the EXTENT in the LAYER object, or wms_extent metadata. Also check that your data exists in the DATA statement
# patch voor juiste proj dir

git apply $DIR/basemaps.patch

# Maken mapfiles
OSM_SRID=28992 OSM_EXTENT="12000 304000 280000 620000" OSM_WMS_SRS="EPSG:4326 EPSG:900913 EPSG:28992 EPSG:3857" make
OSM_SRID=28992 OSM_EXTENT="12000 304000 280000 620000" OSM_WMS_SRS="EPSG:4326 EPSG:900913 EPSG:28992 EPSG:3857" make STYLE=nb

# Doe nu stappen in update en deploy script, behalve imposm --deploy-production-tables
mkdir /mnt/data/osm

# Let op! Indien van een oude server osm_import.backup beschikbaar is, kan deze snel worden geimporteerd om
# Imposm niet te hoeven draaien:

scp iemand@oude.server.nl:/mnt/data/osm/osm_import.backup /mnt/data/osm
/usr/bin/time -f "Time: %E" su - postgres -c 'pg_restore -d osm /mnt/data/osm/osm_import.backup'

$DIR/update.sh

# Let op: zet MAILTO=jouw@email.nl in /etc/crontab en zorg dat bv exim4 dit forwardt naar smarthost!
echo "30 170 * * * root /home/$USER/openbasiskaart/update-cron.sh" >> /etc/crontab

# Link directory met extra mapfiles, zie maps/*.md voor extra instructies

ln -s $DIR/maps /opt

# Web stats

In de Apache configuratie is een `goaccess` log format ingesteld met bovenop het "combined" formaat de processing tijd en het response content type.

Installeer GoAccess 1.4.3 van source, zie https://goaccess.io/.

Link het configuratiebestand:

ln -s /home/$USER/openbasiskaart/goaccess/goaccess.conf /usr/local/etc/goaccess/goaccess.conf

Zorg ervoor dat de stats elke minuut geupdate worden:

`echo "* * * * * root /home/$USER/openbasiskaart/goaccess/cron-goaccess.sh" >> /etc/crontab`

De statistieken zijn te zien via https://www.openbasiskaart.nl/report.html. Dit rapport bevat geen IP-adressen of referrers. Deze zijn voor analyse van overbelasting wel te zien met `goaccess --restore` of `goaccess --restore -o report_all.html --with-output-resolver`.

Backup van stats: directory `/var/lib/goaccess`. Ook oude Apache logs kunnen ingelezen worden (evt ook nog in combined format met `--log-format=COMBINED`).

