#!/bin/bash
IMPOSM=`find /opt -type f -executable -name imposm`
$IMPOSM import -config /opt/openbasiskaart/imposm/config.json -read netherlands-latest.osm.pbf -overwritecache -diff -write -optimize -deployproduction