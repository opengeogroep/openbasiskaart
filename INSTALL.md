Installatieinstructies Openbasiskaart
=====================================

Zoveel mogelijke automatische installatie en setup met cloud-init.

**Installatie op een nieuwe VM**

Lokaal nieuwe VM maken met bijvoorbeeld Multipass (werkt op alle OS'en):

```bash
multipass launch -c 12 -d 60G -m 8G -n obk --mount .:/opt/openbasiskaart --cloud-init cloud-init.yaml 22.04
```

**Installatie op Linux container (LXC)**

Een LXC gebruikt niet z'n eigen kernel dus performt beter.

(TODO)

**Installatie op een Hetzner VM**

Let op: als je geen `--ssh-key` argument gebruikt, wordt er een root account gemaakt met verlopen wachtwoord. Dan kan
door cloud-init niet postgresql worden geinstalleerd omdat geen postgres user account kan worden aangemaakt. Eventueel
kan met cloud-init het wachtwoord op niet-verlopen worden gezet.

```bash
hcloud server create \
    --type cx11 \
    --image ubuntu-22.04 \
    --name openbasiskaart-v3 \
    --ssh-key matthijsln@b3p-matthijs \
    --user-data-from-file cloud-init.yaml
```

Installatie
===========

Nadat je de VM met cloud-init hebt gestart, log in op de server en controleer met `cloud-init status --long` of alles 
ge&iuml;nstalleerd is en check:

```bash
sudo less -S /var/log/cloud-init-output.log
````

Voer daarna uit:
```bash
cd /opt/openbasiskaart
sudo ./install.sh
sudo ./update.sh
/opt/imposm-0.11.1-linux-x86-64/imposm run -config /opt/openbasiskaart/imposm/config.json
```

TODO
====

- [ ] lxc/lxd
- [ ] mapcache seed script extent werkt niet
- [ ] certbot
- [ ] deploy v3, eerst cron update dagelijks
- [ ] mail smarthost
- [ ] munin, goaccess

Verbeteringen
=============

- [ ] Gebruik changes van elke minuut
  - [ ] systemd service voor imposm run (herstart met 5m wacht bij fout?)
  - [ ] mapcache max cache age of delete script (imposm updated tiles in EPSG:3857 of tijd)
  - [ ] monitoring /var/opt/osm/imposm-cache/diff/last.state.txt
  - [ ] website alias voor last.state.txt voor website
  - [ ] elke week volledige import stop imposm-run, import, start imposm-run
  - [ ] wacht met seeden wanneer imposm-run idle (last.state.txt age > 1m)
- [ ] backup: kopieren van/naar extern, restore voor sneller online brengen server
- [ ] PNG grootte optimalisatie door quantization (evt pngcrush)
- [ ] http3: nginx met quiche of eigen quic lib met fastcgi mapcache
- [ ] nginx met fastcgi mapserv voor source
- [ ] Tabel osm_housenumbers niet gebruikt, weghalen uit mapping of styling toevoegen (BGT kan ook)
- [ ] Aparte "light" mapping voor buiten NL
- [ ] Extra stijlen

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

