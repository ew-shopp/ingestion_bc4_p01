#!/bin/bash
tmp_file=$1
continue=true

echo "Worker - Starting using stopfile $tmp_file"

while [ -f $tmp_file ]; do
    echo "Worker - Do copy"
    sleep 60
    echo "Worker - End copy"
done

echo "Worker - Ending"

