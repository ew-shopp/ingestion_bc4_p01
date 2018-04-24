#!/bin/bash

echo '#'
echo '#  Starting Job: Split'
echo '#'

split_file_suffix="${work_directory}/${file_name_no_ext}/${file_name_no_ext}-"
# Debug: Show Paths
echo "!! work_path", ${work_path}
echo "!! extract_directory", ${extract_directory}
echo "!! split_file_suffix", ${split_file_suffix}

# Files are now in the work dir ... ready to be processed

# Split files
mkdir ${extract_directory}

echo "   Split file int work directory"
split -l 800000 --additional-suffix=.csv ${work_path}  ${split_file_suffix}

# Run move_to_output as a subprocess passing all variables
source /code/move_to_output.sh

echo '   Done'

