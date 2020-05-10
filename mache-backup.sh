#!/bin/bash

DIR="/volumeUSB1/usbshare"

rm -rf "${DIR}/backup.9"
mv "${DIR}/backup.8" "${DIR}/backup.9"
mv "${DIR}/backup.7" "${DIR}/backup.8"
mv "${DIR}/backup.6" "${DIR}/backup.7"
mv "${DIR}/backup.5" "${DIR}/backup.6"
mv "${DIR}/backup.4" "${DIR}/backup.5"
mv "${DIR}/backup.3" "${DIR}/backup.4"
mv "${DIR}/backup.2" "${DIR}/backup.3"
mv "${DIR}/backup.1" "${DIR}/backup.2"
cp -al "${DIR}/backup.0" "${DIR}/backup.1"

rsync -av --delete  /volume1/homes/oronso/  "${DIR}/backup.0/" >
/volume1/homes/oronso/bin/mache-backup.log

