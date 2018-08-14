#!/bin/bash

if [ "${MONITOR_JOBS}" = "1" ]; then


    ### Create the id file for the service
    hostname="$(hostname)"
    date="$(date '+%s')"
    hostid="${hostname}_${date}"
    type='service'

    id="$(jo inst=$hostid host=$hostname type=$type)"
    echo "$id" > $SERVICE_ID_FILE_NAME
    
    ### Send start event
    ${CODE_DIRECTORY}/monitor_service_event_n_l_fn_fs.sh "start"
fi     
