#!/bin/bash
# arg1: process_job              
# arg2: code directory
# arg3: input directory
# arg4: work directory
# arg6: output directory
# arg7 ... : application params

process_job=${1}
code_directory=${2}
input_directory=${3}
work_directory=${4}
output_directory=${5}

# Remove first argument to make it easy to pass the remaining params
shift 

echo ${process_job}
echo ${code_directory}
echo ${input_directory}
echo ${work_directory}
echo ${output_directory}
echo '***'

echo '#'
echo '#   Starting: fetch_one_and_process'
echo '#'

# What files to look for ?
input_file_spec=$(${code_directory}/get_input_file_spec.sh)

echo "Searching fil filepattern: ${input_file_spec}"


lock_file="${input_directory}/dir_rw.lock"

new_file_to_process="no"

# Aquire lock
echo "// Aquire lock ${lock_file}"
exec 9>$lock_file
if flock 9; then   # Blocking wait
    
    # Check if there are files to process
    nfiles=`find "${input_directory}" -name "${input_file_spec}" | wc -l`
    if [ "${nfiles}" -gt "0" ]; then
        # Extract File Name in random pos
        file_num=`shuf -i1-${nfiles} -n1`
        input_path=`find "${input_directory}" -name "${input_file_spec}" | head -${file_num} | tail -1`
        echo "// Found ${nfiles} Files"
        echo "// Picking file_num ${file_num}"
        echo "// File to process ${input_path}"

        # Construct Paths
        file_name=${input_path##*/}
        input_path_renamed=${input_path}.inmove
        work_path=${work_directory}/${file_name}

        # Call script to check if file is complete - exit 0 if complete
        ${code_directory}/check_input_file.sh ${input_path}
        retn_code=$?
    
        if [ ${retn_code} -eq 0 ]; then
            # File is ok ... use file

            # Check if file already there
            #ls -l ${input_directory}
            #ls -l ${work_directory}
            found_existing=`find "${work_directory}" -name "${file_name}" | wc -l`
            echo $found_existing
            if [ "${found_existing}" -eq "0" ]; then

                # Move to Workspace
                echo "   Renaming file"
                echo ${input_path}
                echo ${input_path_renamed}
                mv ${input_path} ${input_path_renamed}
                new_file_to_process="yes"

            else
                echo "// File ${file_name} already exists in working dir ... skipping operation"
            fi
        else
            echo "// File ${file_name} failed check ... skipping operation"
        fi
    else
        echo '// No file found ... skipping operation'
    fi
else
    echo '// Lock failed ... skipping operation'
fi

# Release the lock
exec 9>&-

if [ $new_file_to_process == "yes" ]; then
    # Move renamed file to Workspace
    echo "   Moving to Workspace"
    echo ${input_path_renamed}
    echo ${work_path}
    mv ${input_path_renamed} ${work_path}

    # File are now in the work dir ... ready to be processed

    # Run the job 
    ${process_job} "${work_path}" "$@"
else
    echo '// Sleeping 60 Seconds'
    sleep 60
fi


