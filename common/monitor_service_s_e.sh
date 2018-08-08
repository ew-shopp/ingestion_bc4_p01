#!/bin/bash

if [ "${MONITOR_JOBS}" = "1" ]; then
    url=http://monitor:5000
    url=http://localhost:5000
    
    if [ -f "$SERVICE_ID_FILE_NAME" ]; then
        id="$(cat $SERVICE_ID_FILE_NAME)"
        #entry="$(jo id=@$SERVICE_ID_FILE_NAME sub="$1" event="$2")"
        entry="$(jo id=$id sub="$1" event="$2")"
        #echo "monitor_service_s_e: $entry"
        curl -H "Content-type: application/json" \
             -X POST $url/log -d "$entry"
    fi
fi
     
     
