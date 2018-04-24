#!/bin/bash

# arg1: input directory
# arg2: work directory
# arg3: output directory

input_directory=${1}
work_directory=${2}
output_directory=${3}

echo ${input_directory}
echo ${work_directory}
echo ${output_directory}
echo '***'

ls -lisa /usr/bin/*zip

echo '#'
echo '#   Starting: Main'
echo '#'

lock_file="${input_directory}/dir_rw.lock"

while true; do

    new_file_to_process="no"

    # Aquire lock
    exec 9>$lock_file
    # if flock -n 9; then   # No wait
    echo "// Aquire lock ${lock_file}"
    if flock 9; then
        
        # Check if there are files to process
        nfiles=`find ${input_directory} -name "*.csv" | wc -l`
        if [ "${nfiles}" -gt "0" ]; then
                
            # Extract File Name in random pos
            file_num=`shuf -i1-${nfiles} -n1`
            input_path=`find ${input_directory} -name "*.csv" | head -${file_num} | tail -1`
            echo "// Found ${nfiles} Files"
            echo "// Picking file_num ${file_num}"
            echo "// Processing ${input_path}"

            # Construct Paths
            file_name=${input_path##*/}
            file_name_no_ext=${file_name%.*}
            work_path=${work_directory}/${file_name}
            extract_directory=${work_directory}/${file_name_no_ext}
            
            # Debug: Show Paths
            echo "!! file_name", ${file_name}
            echo "!! file_name_no_ext", ${file_name_no_ext}
            echo "!! work_path", ${work_path}
            echo "!! extract_directory", ${extract_directory}
            echo "!! output_directory", ${output_directory}
                
            # Check if file already there
            ls -l ${input_directory}
            ls -l ${work_directory}
            found_existing=`find ${work_directory} -name ${file_name} | wc -l`
            echo $found_existing
            if [ "${found_existing}" -eq "0" ]; then

                
                # Move to Workspace
                echo "   Moving to Workspace"
                echo ${input_path}
                echo ${work_directory}
                mv ${input_path} ${work_directory}
                new_file_to_process="yes"
            else
                echo "// File ${file_name} already exists in working dir ... skipping operation"
            fi
        fi
    else
        echo '// Lock failed ... skipping operation'
    fi
    # Release the lock
    exec 9>&-


    if [ $new_file_to_process == "yes" ]; then
        # Files are now in the work dir ... ready to be processed

        # Run the job as a subprocess passing all variables
        source /code/run_job.sh 
    else
        echo '// Sleeping 60 Seconds'
        sleep 60
    fi
done
