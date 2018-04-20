#!/bin/bash

echo '#'
echo '#  Starting Job: Toarango'
echo '#'
# Debug: Show Paths
echo "!! work_path", ${work_path}
echo "!! transformation_json_full_path", ${transformation_json_full_path}

# Files are now in the work dir ... ready to be processed

# Transforming
echo "   Transforming to Arango Graph"
cd ${work_directory}
node \
    /code/Datagraft-RDF-to-Arango-DB/transformscript.js \
    -t ${transformation_json_full_path} \
    -f ${work_path}


# Run move_to_output as a subprocess passing all variables
source ./move_to_output.sh

echo '   Done'

