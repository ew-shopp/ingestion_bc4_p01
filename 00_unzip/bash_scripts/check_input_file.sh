#!/bin/bash
# arg1: input_path

input_path=${1}

echo "input_path: ${input_path}"
echo '***'

echo '#'
echo '#  Starting : check_input_file'
echo '#'

unzip -t "$input_path" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    exit 0
else
    exit 1
fi
