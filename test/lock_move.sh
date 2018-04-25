#!/bin/bash

lock_file="dir_rw.lock"

echo ${lock_file}

exec 9>$lock_file

echo "Aquiring lock"
if flock -n 9; then
    echo "Starting move"
    mkdir move
    mv *.csv move/
fi
exec 9>&-

echo "Done"

