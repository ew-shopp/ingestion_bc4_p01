#!/bin/bash

echo '#'
echo '#  Starting move_to_output:'
echo '#'
# Debug: Show Paths
echo "!! extract_directory", ${extract_directory}
echo "!! output_directory", ${output_directory}

# Files are now ready processed ... ready to be moved

output_lock_file="${output_directory}/dir_rw.lock"


# Aquire lock
exec 9>$output_lock_file
echo "// Aquire lock ${output_lock_file}"
if flock 9; then
      
    # Move to Output, the lock will assure complete operation before starting to consume
    echo "   Moving From work To Output"
    mv ${extract_directory}/* ${output_directory}

fi
# Release the lock
exec 9>&-

