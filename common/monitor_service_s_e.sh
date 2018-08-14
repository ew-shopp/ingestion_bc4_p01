#!/bin/bash

if [ "${MONITOR_JOBS}" = "1" ]; then
    url=http://monitor:5000
    url=http://localhost:5000
    
    if [ -f "$SERVICE_ID_FILE_NAME" ]; then
        # Fetch service id
        id="$(cat $SERVICE_ID_FILE_NAME)"
        
        # Fetch type
        type_name_script="${CODE_DIRECTORY}/get_type_name.sh"
        type="$(${type_name_script})"
        
        entry="$(jo id="$id" sub="$1" event="$2")"
        #echo "Entry <${entry}>"

        topid="$(jo inst="summary" host="top" type=$type)"
        top="$(jo id="$topid" sub="$entry" event="")"
        #echo "Top <${top}>"

        curl -H "Content-type: application/json" \
             -X POST $url/log -d "$top"
    fi
fi
     
     
