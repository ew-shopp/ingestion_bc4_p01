#!/bin/bash

# arg1: file to lock

input_file=${1}
lock_file="${input_file}.lock"

echo ${lock_file}

exec 9>$lock_file

if flock -n 9; then
    ping vg.no -c 10
fi

ping dagbladet.no -c 5

