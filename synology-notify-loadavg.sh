#!/bin/bash

# Synology: wenn 5 avg_load Minuten Schwellenwert zu hoch, sende
# eine Push-Nachricht (oder was auch immer eingestellt ist, sms, email etc)
# Einstellungen -> Benachrichtigungen -> Erweitert -> 5minute-dings
#
#---[ Einstellungen ]---------------

schwellenwert="1.7"              # vom 5minuten-load Durchschnitt
pause_nach_push=300              # in Sekunden
scan_alle_sekunden=30            # alle 30 Sekunden kontrollieren
log_file="${BASH_SOURCE[0]}.log" # wo das Script selber ist mit .log anhaengsel

#-----------------------------------

echo >> "$log_file"
echo "[$(date)] Script neu gestartet:" >> "$log_file"

counter=0 
push_nachricht=0
push_zeit=0

# das Script 'looped' eine Stunde lang.. dann beendet es sich.
# muss desshalb jede Stunde neu gestartet werden z.B. ueber cron ( 0 * * * *....)

while (( $counter < 3600/$scan_alle_sekunden))
do
  (( counter++ ))
  ok=$(awk -v sw=$schwellenwert '{ print (sw > $2) ? "ja": "nein"; }' /proc/loadavg)
  if [[ $ok == "nein" ]]; then

    zeit=$(date +%s)

    # nur Push-Nachricht, wenn die letzte Push-Nachricht
    # laenger als "pause_nach_push" Sekunden her ist

    if (( $zeit - $push_zeit > $pause_nach_push )); then

      push_zeit=$(date +%s)
      /usr/syno/bin/synonotify PerfEvent_System_CPU_Avg_5
      echo >> "$log_file"
      echo "[$(date)] ALERT: Push-Nachricht gesendet" >> "$log_file"
    fi
  fi
  printf "." >> "$log_file"
  sleep $scan_alle_sekunden
done

echo '[script beendet.]' >> "$log_file"

# fertig..  Stunde (3600 sec) vorbei... ueber cron etc neustarten
