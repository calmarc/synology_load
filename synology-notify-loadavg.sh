#!/bin/bash

# Synology: wenn 5 avg_load minuten schwellenwert zu hoch, sende
# eine Push Nachricht (oder was auch immer eingestellt ist, sms, email etc)
# einstellungen -> benachrichtigungen -> erweitert -> 5minute-dings
#
#---[ Einstellungen ]---------------

schwellenwert="1.7"              # vom 5minuten-load durchschnitt
pause_nach_push=300              # in Sekunden
scan_alle_sekunden=30            # alle 30 Sekunden kontrollieren
log_file="${BASH_SOURCE[0]}.log" # wo das script selber ist mit .log anhaengsel

#-----------------------------------

echo >> "$log_file"
echo "[$(date)] Script neu gestartet:" >> "$log_file"

counter=0 
push_nachricht=0
push_zeit=0

# das script 'looped' eine stunde lang.. dann beendet es sich.
# muss desshalb jede stunde neu gestartet werden  ueber cron ( 0 * * * *....)

while (( $counter < 3600/$scan_alle_sekunden))
do
  (( counter++ ))
  ok=$(awk -v sw=$schwellenwert '{ print (sw > $2) ? "ja": "nein"; }' /proc/loadavg)
  if [[ $ok == "nein" ]]; then

    zeit=$(date +%s)

    # nur push-nachricht, wenn die letzte push_nachricht
    # laenger als 300 sekunden her ist (5 minuten)

    if (( $zeit - $push_zeit > $pause_nach_push )); then

      push_zeit=$(date +%s)
      /usr/syno/bin/synonotify PerfEvent_System_CPU_Avg_5
      echo >> "$log_file"
      echo "[$(date)] ALERT: push nachricht gesendet" >> "$log_file"
    fi
  fi
  sleep $scan_alle_sekunden
  printf "." >> "$log_file"
done

echo '[done]' >> "$log_file"

# fertig..  stunde vorbei... ueber cron etc neustarten
