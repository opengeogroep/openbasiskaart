.. _algemeen:


********
Algemeen
********

Hieronder staat algemene informatie over het hoe en waarom van de OpenGeoGroep (OGG) OpenBasiskaart Nederland (OBKN).
Zie ook de website: http://openbasiskaart.nl. Deze documentatie wordt automatisch gegenereerd vanuit het bijbehorende
GitHub project: https://github.com/opengeogroep/openbasiskaart en heeft de nadruk op de gebruikte techniek.

Waarom OpenBasisKaart ?
=======================

Vanuit zowel OGG-klanten als de OGG-leden is vaker de wens uitgesproken om OpenStreetMap in
de Nederlandse (RD-)projectie beschikbaar te maken.


.. figure:: _static/serving-tiles.png
   :align: center

   *Figuur 1 - Overzicht (bron: http://switch2osm.org/serving-tiles)*

Specificaties
=============

Services: zowel TMS als WMTS, evt WMS-C. WMS heeft niet primair de focus, wel wordt deze in de eerste en derde variant geboden.

Actualiteit: incrementele updates vanuit main OSM DB

Visualisaties: meerdere, gemakkelijk uitbreidbaar

URL: http://openbasiskaart.nl

Projecties: Voor de eerste twee varianten alleen RD, voor de derde variant wordt gewerkt aan ondersteuning van de
de service standaarden voor WMS zoals genoemd op http://www.geonovum.nl/geostandaarden/services/destandaarden

Kaartlagen: voorlopig OSM, later eventueel ook Top10NL en waar mogelijk versterkt met de basisregistraties zoals BAG en BRT

Drie Toolchains
===============

Er zijn meerdere mogelijkheden om vanuit een OSM Planet file uiteindelijk tot tiling en/of OGC webdiensten te komen.
We hebben drie hoofdvarianten uitgezocht, bijgenaamd de "Mapcache Toolchain",  "Mapnik Toolchain" en "GeoServer Toolchain".

In de eerste twee gevallen zal tiling via TMS en WMTS geleverd dienen te worden. In het derde geval zal tiling beschikbaar 
worden gemaakt via WMS-C, TMS en WMTS en zal ook WMS en KML beschikbaar komen. Via MapProxy (1e variant) is ook WMS beschikbaar, zij het
met de tilecache als bron.

Ook willen we onderzoeken in hoeverre we in de eerste twee varianten MBTiles als opslag kunnen gebruiken.

Mapnik Toolchain
----------------

Deze gaat uit van:

- osm2pgsql
- Mapnik
- MBTiles   (ipv file system)
- MapProxy (ipv mod_tile)
- Osmosis (up to date houden tiles)

MapCache Toolchain
------------------

Deze gaat uit van:

- Imposm (importeren OSM Planet data)
- MapServer WMS
- MapCache tiling server
- Tiles op filesysteem
- Styling via MapServer Basemaps: https://github.com/opengeogroep/basemaps

GeoServer Toolchain
-------------------

Deze gaat uit van:

- osm2pgsql
- osmosis
- GeoServer
- MapProxy

Optimalisaties
--------------

http://www.remote.org/frederik/tmp/ramm-osm2pgsql-sotm-2012.pdf    (gebruikt ook Hetzner!)


And The Winner Is...
====================

Uiteindelijk hebben we gekozen voor de MapCache toolchain. De redenen zijn deels rationeel, deels tijdgebrek om de andere
chains volledig uit te werken. De GeoServer toolchain heeft als nadelen: Java (voor sommigen), beperking en
verbosity SLDs. De Mapnik Toolchain was op zich aardig, er waren wat issues met MBTiles in andere projectie en
bleek bovendien redelijk traag t.o.v. filestore, alhoewel natuurlijk een filestore uitstekend gebruikt kan worden.
De MapCache toolchain was gewoon ook het beste uitgewerkt. Styling via MapServer bleek minder een issue dan
gedacht vanwege de beschikbaarheid van MS basemap styles: https://github.com/opengeogroep/basemaps.
Ook zijn een aantal componenten in deze MapCache toolchain goed te integreren/automatiseren, bijv. reseeding
gedreven door OGR sources. De integratie met Apache is ook aantrekkelijk.

Data
====

De proeven met de eerste twee varianten worden uitgevoerd met een beperkt gebied;
Amsterdam e.o. gedownload van: http://metro.teczno.com/#amsterdam

De derde variant bevat momenteel al een OpenStreetMap laag voor Nederland, België, Luxemburg en de gehele
BeNeLux in de WGS84 en de "Spherical Mercator" of "Google" projectie

