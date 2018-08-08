#!/bin/bash

if [ "${MONITOR_JOBS}" = "1" ]; then

    ### Send end event
    ${CODE_DIRECTORY}/monitor_session_event_n_l_fn_fs.sh "end"

    ### Remove the id file for the service
    rm -f $SESSION_ID_FILE_NAME
fi    
     
