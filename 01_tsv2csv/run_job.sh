#!/bin/bash

echo '#'
echo '#  Starting Job: Tsv2csv'
echo '#'
# Debug: Show Paths
echo "!! work_path", ${work_path}
echo "!! work_path_csv", ${work_path_csv}

# Files are now in the work dir ... ready to be processed

# Converting TSV -> CSV
echo "   Converting TSV > CSV"
tr '\t' , < ${work_path} > ${work_path_csv}

# Run move_to_output as a subprocess passing all variables
source ./move_to_output.sh

echo '   Done'

