#!/bin/bash

echo '#  Starting Job: Unzip'
echo '#'
echo '#'
# Debug: Show Paths
echo "!! file_name", ${file_name}
echo "!! file_name_no_ext", ${file_name_no_ext}
echo "!! work_path", ${work_path}
echo "!! extract_directory", ${extract_directory}
echo "!! output_directory", ${output_directory}
echo "!! output_tmp_directory", ${output_tmp_directory}

# Files are now in the work dir ... ready to be processed

# Extract Zip
echo "   Extracting without folder structure"
unzip -j ${work_path} -d ${extract_directory}

# Move Extracted Zip to Output tmp to assure complete operation before starting to consume
echo "   Moving From work To Output tmp"
mkdir ${output_tmp_directory}
mv ${extract_directory}/* ${output_tmp_directory}

echo "   Moving From Output tmp To Output"
# Move Extracted Zip from Output tmp to Output as atomic operation on same volume
mv ${output_tmp_directory}/* ${output_directory}
echo '   Done'

