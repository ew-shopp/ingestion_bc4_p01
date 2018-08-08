#!/bin/bash

if [ "${MONITOR_JOBS}" = "1" ]; then
    url=http://monitor:5000
    url=http://localhost:5000
    
    if [ -f "$SERVICE_ID_FILE_NAME" ]; then
        entry="$(jo id=@$SERVICE_ID_FILE_NAME sub="$1" event="$2")"
        curl -H "Content-type: application/json" \
             -X POST $url/log -d "$entry"
    fi
fi
     
     
