#!/bin/bash
# arg1: input file spec              
# arg2: process_job              
# arg3: code directory
# arg4: input directory
# arg5: work directory
# arg6: output directory
# arg7 ... : application params

input_file_spec=${1}
process_job=${2}
code_directory=${3}
input_directory=${4}
work_directory=${5}
output_directory=${6}

# Remove two first arguments to make it easy to pass the remaining params
shift 2

echo "input_file_spec: ${input_file_spec}"
echo "process_job: ${process_job}"
echo "code_directory: ${code_directory}"
echo "input_directory: ${input_directory}"
echo "work_directory: ${work_directory}"
echo "output_directory: ${output_directory}"
echo '***'

echo '#'
echo '#   Starting: fetch_one_and_process'
echo '#'

lock_file="${input_directory}/dir_rw.lock"

new_file_to_process="no"

echo "// No input lock used"
    
# Check if there are files to process
nfiles="$(find "${input_directory}" -name "${input_file_spec}" | wc -l)"
if [ "${nfiles}" -gt "0" ]; then
    # Extract File Name in random pos
    file_num=`shuf -i1-${nfiles} -n1`
    input_path="$(find "${input_directory}" -name "${input_file_spec}" | head "-${file_num}" | tail -1)"
    echo "// Found ${nfiles} Files"
    echo "// Picking file_num ${file_num}"
    echo "// File to process ${input_path}"

    # Construct Paths
    file_name=${input_path##*/}
    input_path_renamed=${input_path}.inmove
    work_path=${work_directory}/${file_name}
    processed_directory=${work_directory}/__processed__
    processed_path=${processed_directory}/${file_name}

    # Rename file in input folder and check if successful
    echo "   Renaming file ${input_path} ${input_path_renamed}"
    mv ${input_path} ${input_path_renamed}
    retn_code=$?
    if [ ${retn_code} -eq 0 ]; then
        # File rename ok ... use file
        new_file_to_process="yes"

        # Call script to check if file is complete - exit 0 if complete
        ${code_directory}/check_input_file.sh ${input_path_renamed}
        retn_code=$?
        if [ ${retn_code} -eq 0 ]; then
            # Check if file already in work directory
            found_existing="$(find "${work_directory}" -name "${file_name}" | wc -l)"
            if [ "${found_existing}" -ne "0" ]; then
                new_file_to_process="no"
                echo "// File ${file_name} already exists in working dir ... skipping operation"
            fi
        else
            # File is corrupted - cannot use file
            new_file_to_process="no"
            echo "// File ${file_name} failed check ... skipping operation"
        fi
    else
        new_file_to_process="no"
        echo "// File ${file_name} rename failed ... skipping operation"
    fi
else
    echo '// No file found ... skipping operation'
fi

if [ $new_file_to_process == "yes" ]; then
    # Move renamed file to Workspace
    echo "   Moving to Workspace ${input_path_renamed} ${work_path}"
    mv ${input_path_renamed} ${work_path}
    retn_code=$?

    if [ ${retn_code} -eq 0 ]; then
        # File are now in the work dir ... ready to be processed

        # Run the job 
        ${process_job} "${work_path}" "$@"

	# Move the input file to separate dir
	mkdir -p $processed_directory
	mv ${work_path} ${processed_path}

	exit 0
    else
        echo "// File ${file_name} move failed ... skipping operation"
        exit 1
    fi
else
    exit 1
fi


