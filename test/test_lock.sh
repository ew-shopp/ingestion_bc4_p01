#!/bin/bash

# arg1: file to lock

input_file=${1}
lock_file="${input_file}.lock"

echo ${lock_file}

(
    flock -n 9 || exit 1
    ping vg.no -c 30
) 9>$lock_file

ping dagbladet.no -c 5

