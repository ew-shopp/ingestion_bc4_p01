#!/bin/bash

if [ "${MONITOR_JOBS}" = "1" ]; then

    ### Send end event
    ${CODE_DIRECTORY}/monitor_service_event_n_l_fn_fs.sh "end"

    ### Remove the id file for the service
    rm -f $SERVICE_ID_FILE_NAME
fi    
     
