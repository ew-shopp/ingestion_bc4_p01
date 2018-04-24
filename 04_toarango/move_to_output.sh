#!/bin/bash

echo '#'
echo '#  Starting move_to_output:'
echo '#'
# Debug: Show Paths
echo "!! work_path_results", ${work_path_results}
echo "!! output_directory", ${output_directory}

# Files are now ready processed ... ready to be moved

output_lock_file="${output_directory}/dir_rw.lock"


# Aquire lock
exec 9>$output_lock_file
echo "// Aquire lock ${output_lock_file}"
if flock 9; then
      
    # Move to Output, the lock will assure complete operation before starting to consume
    echo "   Moving From work To Output"
    mv ${work_path_results}/${file_name_no_ext}* ${output_directory}

fi
# Release the lock
exec 9>&-

