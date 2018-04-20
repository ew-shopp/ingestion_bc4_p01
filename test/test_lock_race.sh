#!/bin/bash

# arg1: file to lock

input_file=${1}
lock_file="${input_file}.lock"
count_file=${2}
log_file=${3}

echo ${lock_file}

echo "0" > $count_file
while true; do
    exec 9>$lock_file

    if flock  9; then
        COUNTER=$[$(cat $count_file) + 1]
        echo "${COUNTER}"
        echo $COUNTER > $count_file
        echo $COUNTER >> $log_file
        #sleep 1
        #echo "Bye"
    else
        echo "Never here"
    fi
    exec 9>-
done

