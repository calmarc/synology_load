#!/bin/bash

#-- EINSTELLUNGEN - Anzahl backups --

backup_ordner_anzahl=100

# der neuste/juengste/frischeste Backup.. ist zu finden in backup.0
# der backup.1 ist eine Stufe (z.B. ein Tag) aelter.
# der backup.30 ist 30 Stufen (z.B. 30 Tage) aelter.
#
# Wenn also jeden Tag ein Backup hergestellt wird, und man den
# Backup von vor 2 Wochen (14 Tage) haben will - nehme man
# den 'backup.14'
# Den vor 2 Monaten, also 60 Tagen - findet man im Ordner: backup.60

#----------------------------------
LOGFILE="/volume1/homes/oronso/bin/mache-backup.log"

#echo "Versuche Platte einzuhaengen (umount)..."
#echo "Versuche Platte einzuhaengen (umount)..." >> $LOGFILE
#/usr/syno/bin/synousbdisk -mount sdq

#----------------------------------
# gucke ob eine backupplatte gemountet ist
# und finde die DIR variable entsprechend

if [[ ! $(mount | grep usbshare | grep fuseblk.ntfs) ]]
then
    echo
        echo '------[ ACHTUNG ] ----------------------------------------'
        date
        echo 'Die Backupplatte mit 2.8 TB ist nicht eingelegt'
        echo 'Konnte nicht gefunden werden bei der "mount Befehlsausgabe"'
        echo 'Der backup-prozess wird nicht ausgefuehrt!'
        echo '----------------------------------------------------------'
        echo
        echo '------[ ACHTUNG ] ----------------------------------------' >> $LOGFILE
        date >> $LOGFILE
        echo 'Die Backupplatte mit 2.8 TB ist nicht eingelegt' >> $LOGFILE
        echo 'Konnte nicht gefunden werden bei der "mount Befehlsausgabe"' >> $LOGFILE
        echo 'Der backup-prozess wird nicht ausgefuehrt!' >> $LOGFILE
        echo '----------------------------------------------------------' >> $LOGFILE

        /usr/syno/bin/synonotify PerfEvent_System_CPU_Avg_1
        exit 0
fi

DIR=""
if [[ $( df -h | grep '2.8T' | grep '/volumeUSB1/usbshare' ) ]]
then
        DIR="/volumeUSB1/usbshare"
fi
if [[ $( df -h | grep '2.8T' | grep '/volumeUSB2/usbshare' ) ]]
then
        DIR="/volumeUSB2/usbshare"
fi
if [[ $( df -h | grep '2.8T' | grep '/volumeUSB3/usbshare' ) ]]
then
        DIR="/volumeUSB3/usbshare"
fi
if [[ $( df -h | grep '2.8T' | grep '/volumeUSB4/usbshare' ) ]]
then
        DIR="/volumeUSB4/usbshare"
fi

if [ -z $DIR ]
then
        echo '------[ ACHTUNG ] ----------------------------------------'
        date
        echo 'Die Backupplatte mit 2.8 TB ist nicht eingelegt'
        echo 'Konnte nicht gefunden werden via "df -h"'
        echo 'Der backup-prozess wird nicht ausgefuehrt!'
        echo '----------------------------------------------------------'

        echo '------[ ACHTUNG ] ----------------------------------------' >> $LOGFILE
        date >> $LOGFILE
        echo 'Die Backupplatte mit 2.8 TB ist nicht eingelegt' >> $LOGFILE
        echo 'Konnte nicht gefunden werden via "df -h"' >> $LOGFILE
        echo 'Der backup-prozess wird nicht ausgefuehrt!' >> $LOGFILE
        echo '----------------------------------------------------------' >> $LOGFILE

        /usr/syno/bin/synonotify PerfEvent_System_CPU_Avg_1
        exit 0
fi

echo "------[ BACKUP vom $(date) ] -------" >> $LOGFILE
echo "------[ BACKUP vom $(date) ] -------"
echo "" >> $LOGFILE
echo "" 
echo "BackupPlatte ist gemounted an: [${DIR}]" >> $LOGFILE
echo "BackupPlatte ist gemounted an: [${DIR}]"

# ------------------------------------------------------
# Backup Ordner
# 3->4. 2->3. 1->2.

i=$backup_ordner_anzahl

if [ -d "${DIR}/backup.0" ]
then
  # erhoehe ab und mit 1 um 1
  echo "erhoehe alle backup-nummern um 1..."
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

rsync -av --delete  /volume1/homes/oronso/  "${DIR}/backup.0/" >> ${LOGFILE}

# ------------------------------------------------------
# log....

echo "" >> ${LOGFILE}
echo ""
echo $(du -sh ${DIR}/backup.5) " (vor 5 Tagen)"  >> ${LOGFILE}
echo $(du -sh ${DIR}/backup.5) " (vor 5 Tagen)"
echo $(du -sh ${DIR}/backup.4) " (vor 4 Tagen)"  >> ${LOGFILE}
echo $(du -sh ${DIR}/backup.4) " (vor 4 Tagen)"
echo $(du -sh ${DIR}/backup.3) " (vor 3 Tagen)"  >> ${LOGFILE}
echo $(du -sh ${DIR}/backup.3) " (vor 3 Tagen)"
echo $(du -sh ${DIR}/backup.2) " (vor 2 Tagen)"  >> ${LOGFILE}
echo $(du -sh ${DIR}/backup.2) " (vor 2 Tagen)"
echo $(du -sh ${DIR}/backup.1) " (vor 1-nem Tag)" >> ${LOGFILE}
echo $(du -sh ${DIR}/backup.1) " (vor 1-nem Tag)"
echo $(du -sh ${DIR}/backup.0) " (aktuelles Backup)" >> ${LOGFILE}
echo $(du -sh ${DIR}/backup.0) " (aktuelles Backup)"
echo "" >> ${LOGFILE}
echo ""
echo $(df -h | grep ${DIR}) " (Backupplatte Platz)" >> ${LOGFILE}
echo $(df -h | grep ${DIR}) " (Backupplatte Platz)"

echo "" >> ${LOGFILE}
echo ""

#echo "Versuche Platte auszuhaengen (umount)..."
#cho "Versuche Platte auszuhaengen (umount)..." >> $LOGFILE
#/usr/syno/bin/synousbdisk -umount sdq

echo "------[ ... beendet ] -------" >> $LOGFILE
echo "------[ ... beendet ] -------"
echo "" >> ${LOGFILE}
echo ""

