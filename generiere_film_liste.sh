#!/bin/bash

cd /volume1/video/
find  Filme_1-9/ Filme_A-E/ Filme_F-M/ Filme_N-Z/ Filme_The/ Kiddies/ Marvel/ James_Bond/ Bud_Spencer/ -maxdepth 1 -type f | sed "/vsmeta/d" |  sed "/cuts$/d" | sed "s%.*/%%" | sed "s%++%%" | sed "/humbs/d" | sed "/^$/d" | sed "/eaDir/d" | sed "s/\./ /g" | sed "s/mkv$//" | sort > ~/Filmliste_Alpha.txt

find  Filme_1-9/ Filme_A-E/ Filme_F-M/ Filme_N-Z/ Filme_The/ Kiddies/ Marvel/ James_Bond/ Bud_Spencer/ -maxdepth 1 -type f | sed "/vsmeta/d" |  sed "/cuts$/d" | sed "s%.*/%%" | sed "s%++%%" | sed "/humbs/d" | sed "/^$/d" | sed "/eaDir/d" | sed "s/\./ /g" | sed "s/mkv$//" | sort -r -t "(" -n -k2 > ~/Filmliste_Jahr.txt
