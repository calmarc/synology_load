#!/bin/bash

# Lieder: wenn mehr als fuenf vom der gleichen Gruppe, mache so einen
# Ordner und tue die rein.

find . -type f -name "*"| while read filen;
do

   b=${filen%-*} # vom Anfang bis zum '-'

   if [ -d "${b}" ]; then
     echo  "Kopiere in Ordner: mv '${filen}' [${b}]"
     mv "${filen}" "${b}"
     continue
   fi

   # alles nach dem ./ (${b#./}

   x=$(find . -maxdepth 1 -type f -name "${b#./}*" | wc -l)

   if (( x > 5 ))
   then 
     echo "Erstelle Ordner [${b}] und verschiebe darin: '${filen}'"
     mkdir "${b}"
     mv "${filen}" "${b}"
   fi
done