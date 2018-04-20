#!/bin/bash

echo '#'
echo '#  Starting Job: Unzip'
echo '#'
# Debug: Show Paths
echo "!! work_path", ${work_path}
echo "!! extract_directory", ${extract_directory}

# Files are now in the work dir ... ready to be processed

# Extract Zip
echo "   Extracting without folder structure"
unzip -j ${work_path} -d ${extract_directory}

# Run move_to_output as a subprocess passing all variables
source ./move_to_output.sh

echo '   Done'

