#!/bin/bash
move_to_dir=$1

n_processed=$(find * | grep '__processed__/' | wc -l)

while [ "${n_processed}" -gt "0" ]; do
    # move one processed file
    processed_path="$(find * | grep '__processed__/' | head -1)"
    mv $processed_path $move_to_dir

    n_processed=$(find * | grep '__processed__/' | wc -l)
done


