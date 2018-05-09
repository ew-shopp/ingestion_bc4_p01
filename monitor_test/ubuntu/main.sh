#!/bin/bash
# arg1: tmp file              

tmp_file=${1}


echo ${tmp_file}


echo '#'
echo '#   Starting: Main'
echo '#'


while [ -f $tmp_file ]; do
    echo "Go to sleep"
    /code/send_to_monitor.sh "Sleep"
    sleep 7
done
echo "Done"
/code/send_to_monitor.sh "Done"

