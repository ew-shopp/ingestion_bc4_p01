#!/bin/bash

if [ "${MONITOR_JOBS}" = "1" ]; then
    if [ -f "$SESSION_ID_FILE_NAME" ]; then
        id="$(cat $SESSION_ID_FILE_NAME)"
        #entry="$(jo id=@$SESSION_ID_FILE_NAME sub="$1" event="$2")"
        entry="$(jo id=$id sub="$1" event="$2")"
        ${CODE_DIRECTORY}/monitor_service_s_e.sh "$entry" ""
    fi
fi
     
