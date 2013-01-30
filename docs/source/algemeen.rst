.. _algemeen:


********
Algemeen
********

Hieronder staat algemene informatie over het hoe en waarom van de OpenGeoGroep Basiskaart.
Zie ook de website: http://basiskaart.opengeogroep.nl

Waarom OpenGeoGroep Basiskaart ?
================================

Vanuit zowel OGG-klanten als de OGG-leden is vaker de wens uitgesproken om OpenStreetMap tiles in
de Nederlandse (RD-)projectie beschikbaar te maken. (Nog af te maken)....


.. figure:: _static/serving-tiles.png
   :align: center

   *Figuur 1 - Overzicht (bron: http://switch2osm.org/serving-tiles)*

Specificaties
=============

Services: zowel TMS als WMTS, evt WMS-C. Voorlopig geen WMS.

Actualiteit: incrementele updates vanuit main OSM DB

Visualisaties: meerdere, gemmakkelijk uitbreidbaar

URL: http://basiskaart.opengeogroep.nl

Projecties: alleen RD (??)

Kaartlagen: voorlopig OSM, later ook Top10NL en BAG

Twee Toolchains
===============

Er zijn meerdere mogelijkheden om vanuit een OSM Planet file uiteindelijk tot tiling webdiensten te komen.
We hebben twee hoofdvarianten uitgezocht, bijgenaamd de "Mapcache Toolchain" en de "Mapnik Toolchain".

In beide gevallen zal tiling via TMS en WMTS geleverd dienen te worden.

Ook willen we onderzoeken in hoeverre we in beide varianten MBTiles als opslag kunnen gebruiken.

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

Optimalisaties
--------------

http://www.remote.org/frederik/tmp/ramm-osm2pgsql-sotm-2012.pdf    (gebruikt ook Hetzner!)


Data
====

Om niet meteen heel NL te hoeven laden/tilen etc. werken we eerst met kleiner gebied, Amsterdam e.o.
Download van: http://metro.teczno.com/#amsterdam


