#!/bin/bash

if [ "${MONITOR_JOBS}" = "1" ]; then


    ### Create and send session event
    event="$(${CODE_DIRECTORY}/monitor_make_event_n_l_fn_fs.sh "$@")"
    ${CODE_DIRECTORY}/monitor_session_s_e.sh "" "$event"
fi     
