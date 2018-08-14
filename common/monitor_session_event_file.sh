#!/bin/bash

if [ "${MONITOR_JOBS}" = "1" ]; then

    name=$1
    file_path=$2
    file_name=${file_path##*/}
    file_size=$(stat -c %s $file_path)
    log="$file_path \n $(ls -lh $file_path)"

    ### Create and send session event
    event="$(${CODE_DIRECTORY}/monitor_make_event_n_l_fn_fs.sh "$name" "$log" "$file_name" "$file_size" )"

    ${CODE_DIRECTORY}/monitor_session_s_e.sh "" "$event"
fi     
