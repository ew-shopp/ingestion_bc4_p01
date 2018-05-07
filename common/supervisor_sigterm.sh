#!/bin/bash
function gracefulshutdown {
    echo "Supervisor - Received signal to shut down"
    echo "Supervisor - Deleting run-file"
    rm $run_file_name
}

# Worker script to run
cmd_to_run="/code/main.sh"

echo "Supervisor - Starting"

# Make tmp file ... run until file is deleted
mkdir /work/run
run_file_name=`mktemp --tmpdir=run/ --suffix=.run`

trap gracefulshutdown SIGINT SIGTERM

echo "Supervisor - Starting worker script $1 $run_file_name"
$cmd_to_run $run_file_name "$@" &

echo "Supervisor - Wait..."
wait %1

echo "Supervisor - End"

