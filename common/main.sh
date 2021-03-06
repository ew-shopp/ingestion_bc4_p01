#!/bin/bash

function gracefulshutdown {
    echo "Main - Received signal to shut down"
    echo "Main - Deleting run-file"
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


# Worker script to run
cmd_to_run="${code_directory}/main_worker.sh"

echo "Main - Starting"

# Execute init if present
init_script="${code_directory}/init.sh"
if [ -f "$init_script" ]; then
   $init_script
fi

# Make tmp file ... run until file is deleted
mkdir -p $work_directory/run
run_file_name=`mktemp -t -p ${work_directory}/run`

# Make unique working directory
unique_work_directory="${work_directory}/HOST_${HOSTNAME}"
mkdir -p $unique_work_directory

trap gracefulshutdown SIGINT SIGTERM

echo "Main - Starting $run_file_name with working dir set to $unique_work_directory"
$cmd_to_run $run_file_name "${@:1:3}" "$unique_work_directory" "${@:5}" &
pid=$!

# This will wait until the cmd ends or we receive SIGINT
wait $pid

echo "Main - Wait for worker to end ..."
wait $pid

# Cleanup
rm -f $run_file_name

echo "Main - End"

