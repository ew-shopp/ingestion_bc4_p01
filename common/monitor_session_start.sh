#!/bin/bash

if [ "${MONITOR_JOBS}" = "1" ]; then


    ### Create the id file for the session
    date="$(date '+%Y%m%d_%T_%N')"
    type='session'
    id="$(jo inst=$date type=$type)"
    echo "$id" > $SESSION_ID_FILE_NAME
    
    
    ### Send start event
    ${CODE_DIRECTORY}/monitor_session_event_n_l_fn_fs.sh "start"
fi     
