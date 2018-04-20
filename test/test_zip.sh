#!/bin/bash

# arg1: file to test

input_file=${1}

echo ${input_file}
ret_val=`unzip -t $input_file`
#echo $?
if [ $? -eq 0 ]; then
    echo "ok"
else
    echo "error"
fi

