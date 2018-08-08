#!/bin/bash

function gracefulshutdown {
    echo "Main - Received signal to shut down"
    echo "Main - Deleting run-file"
    ${CODE_DIRECTORY}/monitor_service_event_n_l_fn_fs.sh "service_shutdown"
    rm $run_file_name
}

# arg1: retry_max_count
# arg2: code directory
# arg3: input directory
# arg4: work directory
# arg5: output directory
# arg6... : application params

retry_max_count=${1}
code_directory=${2}
input_directory=${3}
work_directory=${4}
output_directory=${5}

export CODE_DIRECTORY=$code_directory

# Worker script to run
cmd_to_run="main_worker.sh"

echo "Main - Starting"

# Execute init if present
init_script="${code_directory}/init.sh"
if [ -f "$init_script" ]; then
   $init_script
fi

# Make tmp file ... run until file is deleted
mkdir -p $work_directory/run
run_file_name=`mktemp -t -p ${work_directory}/run`
service_id_file_name="${run_file_name}.serviceid"
export SERVICE_ID_FILE_NAME=$service_id_file_name

${CODE_DIRECTORY}/monitor_service_start.sh

trap gracefulshutdown SIGINT SIGTERM

echo "Main - Starting $run_file_name"
${CODE_DIRECTORY}/$cmd_to_run $run_file_name "$@" &
pid=$!

# This will wait until the cmd ends or we receive SIGINT
wait $pid

echo "Main - Wait for worker to end ..."
wait $pid

${CODE_DIRECTORY}/monitor_service_end.sh

# Cleanup
rm -f $run_file_name*

echo "Main - End"

