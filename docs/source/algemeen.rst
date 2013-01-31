.. _algemeen:


********
Algemeen
********

Hieronder staat algemene informatie over het hoe en waarom van de OpenGeoGroep Basiskaart.
Zie ook de website: http://basiskaart.opengeogroep.nl. Deze documentatie wordt automatisch gegenereerd vanuit het bijbehorende
GitHub project: https://github.com/opengeogroep/basiskaart

Waarom OpenGeoGroep Basiskaart ?
================================

Vanuit zowel OGG-klanten als de OGG-leden is vaker de wens uitgesproken om OpenStreetMap in
de Nederlandse (RD-)projectie beschikbaar te maken.


.. figure:: _static/serving-tiles.png
   :align: center

   *Figuur 1 - Overzicht (bron: http://switch2osm.org/serving-tiles)*

Specificaties
=============

Services: zowel TMS als WMTS, evt WMS-C. WMS heeft niet primair de focus, wel wordt deze in de derde variant geboden.

Actualiteit: incrementele updates vanuit main OSM DB

Visualisaties: meerdere, gemmakkelijk uitbreidbaar

URL: http://basiskaart.opengeogroep.nl

Projecties: Voor de eerste twee varianten alleen RD, voor de derde variant wordt gewerkt aan ondersteuning van de 
de service standaarden voor WMS zoals genoemd op http://www.geonovum.nl/geostandaarden/services/destandaarden

Kaartlagen: voorlopig OSM, later eventueel ook Top10NL en waar mogelijk versterkt met de basisregistraties zoals BAG en BRT

Drie Toolchains
===============

Er zijn meerdere mogelijkheden om vanuit een OSM Planet file uiteindelijk tot tiling en/of OGC webdiensten te komen.
We hebben twee hoofdvarianten uitgezocht, bijgenaamd de "Mapcache Toolchain" en de "Mapnik Toolchain". Daarnaast is 
er momenteel een derde variant in ontwikkeling; de "GeoServer Toolchain"

In de eerste twee gevallen zal tiling via TMS en WMTS geleverd dienen te worden. In het derde geval zal tiling beschikbaar 
worden gemaakt via WMS-C, TMS en WMTS en zal ook WMS en KML beschikbaar komen

Ook willen we onderzoeken in hoeverre we in de eerste twee varianten MBTiles als opslag kunnen gebruiken.

Mapnik Toolchain
----------------

Deze gaat uit van:

- osm2pgsql
- mapnik
- MBTiles   (ipv file system)
- MapProxy (ipv mod_tile)
- osmosis (up to date houden tiles)

Mapcache Toolchain
------------------

Deze gaat uit van:

- Imposm
- Mapcache
- MapServer
- MBTiles   (ipv file system)
- ??

GeoServer Toolchain
------------------
- osm2pgsql
- osmosis
- GeoServer
- MapProxy

Optimalisaties
--------------

http://www.remote.org/frederik/tmp/ramm-osm2pgsql-sotm-2012.pdf    (gebruikt ook Hetzner!)


Data
====

De proeven met de eerste twee varianten worden uitgevoerd met een beperkt gebied;
Amsterdam e.o. gedownload van: http://metro.teczno.com/#amsterdam

De derde variant bevat momenteel al een OpenStreetMap laag voor Nederland, België, Luxemburg en de gehele
BeNeLux in de WGS84 en de "Spherical Mercator" of "Google" projectie

