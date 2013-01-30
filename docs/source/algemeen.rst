.. _algemeen:


********
Algemeen
********

Hieronder staat algemene informatie over het hoe en waarom van de OpenGeoGroep Basiskaart.
Zie ook de website: http://basiskaart.opengeogroep.nl

Waarom OpenGeoGroep Basiskaart ?
================================

(Verhaal waarom dit project in het leven geroepen)

Onderzoek: 2 Toolchains
=======================

Er zijn meerdere mogelijkheden om vanuit een OSM Planet file uiteindelijk tot tiling webdiensten te komen.
We hebben twee hoofdvarianten uitgezocht, genaamd de "Mapcache Toolchain" en de "Mapnik Toolchain".

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
