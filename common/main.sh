#!/bin/bash

function gracefulshutdown {
    echo "Main - Received signal to shut down"
    echo "Main - Deleting run-file"
    rm $run_file_name
}

# arg1: code directory
# arg2: input directory
# arg3: work directory
# arg4: output directory
# arg5... : application params

code_directory=${1}
input_directory=${2}
work_directory=${3}
output_directory=${4}


# Worker script to run
cmd_to_run="${code_directory}/main_worker.sh"

echo "Main - Starting"

# Make tmp file ... run until file is deleted
mkdir -p $work_directory/run
run_file_name=`mktemp -t -p ${work_directory}/run`

trap gracefulshutdown SIGINT SIGTERM

echo "Main - Starting $run_file_name"
$cmd_to_run $run_file_name "$@" &
pid=$!

# This will wait until the cmd ends or we receive SIGINT
wait $pid

echo "Main - Wait for worker to end ..."
wait $pid

# Cleanup
rm -f $run_file_name

echo "Main - End"

