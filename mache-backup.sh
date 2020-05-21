#!/bin/bash

#-- EINSTELLUNGEN - Anzahl backups --

BACKUP_ORDNER_ANZAHL=1000

# backup.0 ist der neuste. backup.1 stufe aelter. backup.2 noch aelter etc

#----------------------------------
LOGFILE="/volume1/homes/oronso/bin/mache-backup.log"

#echo "Versuche Platte einzuhaengen (umount)..." | tee -a $LOGFILE
#/usr/syno/bin/synousbdisk -mount sdq

#----------------------------------
# gucke ob eine backupplatte gemountet ist
# und finde die DIR variable entsprechend

if [[ ! $(mount | grep usbshare | grep fuseblk.ntfs) ]]
then
    echo
        echo '------[ ACHTUNG ] ----------------------------------------' | tee -a $LOGFILE
        date | tee -a $LOGFILE
        echo 'Die Backupplatte mit 2.8 TB ist nicht eingelegt' | tee -a $LOGFILE
        echo 'Konnte nicht gefunden werden bei der "mount Befehlsausgabe"' | tee -a $LOGFILE
        echo 'Der backup-prozess wird nicht ausgefuehrt!' | tee -a $LOGFILE
        echo '----------------------------------------------------------' | tee -a $LOGFILE

        /usr/syno/bin/synonotify PerfEvent_System_CPU_Avg_1
        exit 0
fi

DIR=""
if [[ $( df -h | grep '2.8T' | grep '/volumeUSB1/usbshare' ) ]]
then
        DIR="/volumeUSB1/usbshare"
elif [[ $( df -h | grep '2.8T' | grep '/volumeUSB2/usbshare' ) ]]
then
        DIR="/volumeUSB2/usbshare"
elif [[ $( df -h | grep '2.8T' | grep '/volumeUSB3/usbshare' ) ]]
then
        DIR="/volumeUSB3/usbshare"
elif [[ $( df -h | grep '2.8T' | grep '/volumeUSB4/usbshare' ) ]]
then
        DIR="/volumeUSB4/usbshare"
fi

if [ -z $DIR ]
then
        echo '------[ ACHTUNG ] ----------------------------------------' | tee -a $LOGFILE
        date | tee -a $LOGFILE
        echo 'Die Backupplatte mit 2.8 TB ist nicht eingelegt' | tee -a $LOGFILE
        echo 'Konnte nicht gefunden werden via "df -h"' | tee -a $LOGFILE
        echo 'Der backup-prozess wird nicht ausgefuehrt!' | tee -a $LOGFILE
        echo '----------------------------------------------------------' | tee -a $LOGFILE

        /usr/syno/bin/synonotify PerfEvent_System_CPU_Avg_1
        exit 0
fi

echo "------[ BACKUP vom $(date) ] -------" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE
echo "BackupPlatte ist gemounted an: [${DIR}]" | tee -a $LOGFILE

# ------------------------------------------------------
# Backup Ordner
# 3->4. 2->3. 1->2.

i=$BACKUP_ORDNER_ANZAHL

if [ -d "${DIR}/backup.0" ]
then
  # erhoehe ab und mit 1 um 1
  echo "Erhoehe alle backup-nummern um 1..." | tee -a $LOGFILE
  while [ "$i" -gt 1 ]
  do
    o=$((i))
    i=$((i-1))
    [ -d "${DIR}/backup.${i}" ] && mv "${DIR}/backup.${i}"  "${DIR}/backup.${o}"
  done
fi

# ------------------------------------------------------
# kopiere (hard-links) 0 in 1 .. und rsync'e 0

cp -al "${DIR}/backup.0" "${DIR}/backup.1"

# damit die Ordner das Datum haben wann der backup gemacht wurde

rsync -av --delete  /volume1/homes/oronso/  "${DIR}/backup.0/" | tee -a ${LOGFILE}

touch "${DIR}/backup.0"

# ------------------------------------------------------
# log....

echo "" | tee -a ${LOGFILE}
echo $(du -sh ${DIR}/backup.3) " (vor 3 Tagen)" | tee -a ${LOGFILE}
echo $(du -sh ${DIR}/backup.2) " (vor 2 Tagen)" | tee  -a ${LOGFILE}
echo $(du -sh ${DIR}/backup.1) " (vor 1-nem Tag)" | tee  -a ${LOGFILE}
echo $(du -sh ${DIR}/backup.0) " (aktuelles Backup)" | tee -a ${LOGFILE}
echo "" | tee -a ${LOGFILE}
echo $(df -h | grep ${DIR}) " (Backupplatte Platz)" | tee -a ${LOGFILE}

echo "" | tee -a ${LOGFILE}

#cho "Versuche Platte auszuhaengen (umount)..." | tee -a $LOGFILE
#/usr/syno/bin/synousbdisk -umount sdq

date | tee -a $LOGFILE
echo "------[ ... beendet ] -------" | tee -a $LOGFILE
echo "" | tee -a ${LOGFILE}

