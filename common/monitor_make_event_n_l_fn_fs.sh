#!/bin/bash
event="{}"
if [ "${MONITOR_JOBS}" = "1" ]; then

    name=$1
    log=$2
    filename=$3
    filesize=$4
    
    ### Create an event json object
    date_iso="$(date '--iso-8601=seconds')"
    date_epoch="$(date '+%s')"
    event=$(jo name="$name" log="$log" filename="$filename" filesize="$filesize" type="event" time_iso="$date_iso" time_epoch="$date_epoch" )
fi
echo $event
     
