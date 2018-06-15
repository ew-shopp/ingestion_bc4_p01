#!/bin/bash
# arg1: tmp file              
# arg2: code directory
# arg3: input directory
# arg4: work directory
# arg5: output directory
# arg6 ... : application params

tmp_file=${1}
code_directory=${2}
input_directory=${3}
work_directory=${4}
output_directory=${5}

# Remove first argument to make it easy to pass the remaining params
shift

echo ${tmp_file}
echo ${code_directory}
echo ${input_directory}
echo '***'

echo '#'
echo '#   Starting: main_worker'
echo '#'


lock_file="${input_directory}/dir_rw.lock"

while [ -f $tmp_file ]; do
    new_file_to_process="no"

    # What files to look for ?
    input_file_spec=$(${code_directory}/get_input_file_spec.sh)
    
    # Call script to find a file and process it 
    ${code_directory}/fetch_one_and_process.sh "${input_file_spec}" "${code_directory}/process_job.sh" "$@"
done

