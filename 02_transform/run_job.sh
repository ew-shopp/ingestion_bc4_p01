#!/bin/bash

echo '#'
echo '#  Starting Job: Transform'
echo '#'
# Debug: Show Paths
echo "!! work_path", ${work_path}
echo "!! transformation_full_path", ${transformation_full_path}
echo "!! work_path_transformed", ${work_path_transformed}

# Files are now in the work dir ... ready to be processed

# Transforming
echo "   Transforming"
# java -Xmx4g -jar /code/transformation-csv3.jar \
java -Xmx8g -jar ${transformation_full_path} \
    ${work_path} \
    ${work_path_transformed}


ls -l $work_directory

# Run move_to_output as a subprocess passing all variables
source /code/move_to_output.sh

echo '   Done'

