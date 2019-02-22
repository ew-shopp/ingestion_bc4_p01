#!/bin/sh
# arg1: file to test

tail_1="$(tail --bytes=1000 "$1" | md5sum)"
sleep 10

while true; do
    # echo "$tail_1"
    tail_2="$(tail --bytes=1000 "$1" | md5sum)"
    if [ "$tail_1" = "$tail_2" ]
    then
        echo "// File $1 unchanged"
    else
        echo "// File $1 modified ********************"
    fi
    tail_1=$tail_2
    sleep 10
done
