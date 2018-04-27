#!/bin/bash

echo '#'
echo '#  Starting move_to_output:'
echo '#'
# Debug: Show Paths
echo "!! work_path_transformed", ${work_path_transformed}
echo "!! output_path_renamed", ${output_path_renamed}
echo "!! output_path", ${output_path}

# Files are now ready processed ... ready to be moved

echo "   Moving From work To Output as renamed file"
mv ${work_path_transformed} ${output_path_renamed}


output_lock_file="${output_directory}/dir_rw.lock"

# Aquire lock
exec 9>$output_lock_file
echo "// Aquire lock ${output_lock_file}"
if flock 9; then
      
    # Rename file in output dir and assure complete operation before starting to consume
    echo "   Rename file in output dir"
    mv ${output_path_renamed} ${output_path}

fi
# Release the lock
exec 9>&-

