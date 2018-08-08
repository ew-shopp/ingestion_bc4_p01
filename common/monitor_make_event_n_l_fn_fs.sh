#!/bin/bash
event="{}"
if [ "${MONITOR_JOBS}" = "1" ]; then

    name=$1
    log=$2
    filename=$3
    filesize=$4
    
    ### Create an event json object
    date="$(date '--iso-8601=seconds')"
    event=$(jo name="$name" log="$log" filename="$filename" filesize="$filesize" type="event" time="$date" )
fi
echo $event
     
