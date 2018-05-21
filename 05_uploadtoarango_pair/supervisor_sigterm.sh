#!/bin/bash

function gracefulshutdown {
    echo "Supervisor - Received signal to shut down"
    echo "Supervisor - Deleting run-file"
    rm $run_file_name
}

# arg1: input directory
# arg2: work directory
# arg3: output directory

input_directory=${1}
work_directory=${2}
output_directory=${3}

echo ${input_directory}
echo ${work_directory}
echo ${output_directory}

# Worker script to run
cmd_to_run="/code/main.sh"
#cmd_to_run=$1

echo "Supervisor - Starting"

# Make tmp file ... run until file is deleted
mkdir -p ${work_directory}/run
run_file_name=`mktemp -t -p ${work_directory}/run`

trap gracefulshutdown SIGINT SIGTERM

echo "Supervisor - Starting worker script ${1} ${run_file_name}"
$cmd_to_run $run_file_name "$@" &
pid=$!

# This will wait until the cmd ends or we receive SIGINT
wait $pid

echo "Supervisor - Wait for worker to end ..."
wait $pid

# Cleanup
rm -f ${run_file_name}

echo "Supervisor - End"

