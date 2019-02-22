#!/bin/bash
# arg1: output directory
# arg2 ... : files to move

output_directory=${1}

# Remove the first argument to make it easy to loop through files
shift

echo "output_directory: ${output_directory}"
#echo $@
echo '***'

echo '#'
echo '#   Starting: move_to_output'
echo '#'


output_lock_file="${output_directory}/dir_rw.lock"

# Loop through all files in argument list
while [ "$1" ]
do
    from_file_path=${1}
    file_name=${from_file_path##*/}
    to_file_path=${output_directory}/${file_name}
    to_file_path_renamed=${to_file_path}.outmove
    shift
    
    ${code_directory}/now_entry.sh "Move_outfile_1 ${from_file_path}"
    echo "   Moving file ${from_file_path} to ${to_file_path_renamed}"
    mv ${from_file_path} ${to_file_path_renamed}
    ${code_directory}/now_entry.sh "Move_outfile_2 ${from_file_path}"
    
#    # Aquire lock
#    exec 9>$output_lock_file
#    echo "// Aquire lock ${output_lock_file}"
#    if flock 9; then   # Blocking wait
    echo "// No output lock used"
          
        # Rename file in output dir to assure complete operation before starting to consume
        echo "   Rename file in output dir ${to_file_path_renamed} ${to_file_path}"
        ${code_directory}/now_entry.sh "Rename_outfile_1 ${to_file_path_renamed}"
        mv ${to_file_path_renamed} ${to_file_path}
        ${code_directory}/now_entry.sh "Rename_outfile_2 ${to_file_path_renamed}"

#    fi
#    # Release the lock
#    exec 9>&-

done


