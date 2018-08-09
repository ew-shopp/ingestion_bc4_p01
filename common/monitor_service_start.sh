#!/bin/bash

if [ "${MONITOR_JOBS}" = "1" ]; then


    ### Create the id file for the service
    hostname="$(hostname)"
    #date="$(date '+%Y%m%d_%T_%N')"
    date="$(date '+%s')"
    hostid="${hostname}_${date}"
    type='???'
    # Fetch type if present
    type_name_script="${CODE_DIRECTORY}/get_type_name.sh"
    if [ -f "$type_name_script" ]; then
       type="$(${type_name_script})"
    fi
    id="$(jo inst=$hostid host=$hostname type=$type)"
    echo "$id" > $SERVICE_ID_FILE_NAME
    
    
    ### Send start event
    ${CODE_DIRECTORY}/monitor_service_event_n_l_fn_fs.sh "start"
fi     
