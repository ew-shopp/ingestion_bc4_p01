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
echo '#'
echo '#'
pwd


while true; do

    new_file_to_process="no"

    nfiles=`find ${input_directory} -name "*.zip" | wc -l`
    if [ "${nfiles}" -gt "0" ]; then
            
        # Extract File Name in random pos
        file_num=`shuf -i1-${nfiles} -n1`
        input_path=`find ${input_directory} -name "*.zip" | head -${file_num} | tail -1`
        echo "// Found ${nfiles} Files"
        echo "// Picking file_num ${file_num}"
        echo "// Processing ${input_path}"

        # Construct Paths
        file_name=${input_path##*/}
        file_name_no_ext=${file_name%.*}
        work_path=${work_directory}/${file_name}
        extract_directory=${work_directory}/${file_name_no_ext}
        output_tmp_directory=${output_directory}/${file_name_no_ext}
        
        
        # Debug: Show Paths
        echo "!! file_name", ${file_name}
        echo "!! file_name_no_ext", ${file_name_no_ext}
        echo "!! work_path", ${work_path}
        echo "!! extract_directory", ${extract_directory}
        echo "!! output_directory", ${output_directory}
        echo "!! output_tmp_directory", ${output_tmp_directory}

        # Aquire lock
        input_path_no_ext=${input_path%.*}
        lock_file="${input_path_no_ext}.lock"
        exec 9>$lock_file
        if flock -n 9; then
            echo "// Aquired lock ${lock_file}"
            
            # Check if file already there
            found_existing=`find ${work_directory} -name ${file_name} | wc -l`
            if [ "${found_existing}" -eq "0" ]; then

                # Check if valid zip file
                ret_val=`unzip -t $input_path > /dev/null 2>&1`
                if [ $? -eq 0 ]; then
                    echo "!! Zip file ok"
                
                
                    new_file_to_process="mv"
                    # Move Zip to Workspace
                    echo "   Moving Zip to Workspace"
                    mv ${input_path} ${work_directory}
                    new_file_to_process="yes"
                else
                    echo "// ZIP file error ... skipping operation"
                fi
            else
                echo "// File ${file_name} already exists in working dir ... skipping operation"
            fi
        else
            echo '// Lock failed ... skipping operation'
        fi
        # Release the lock
        exec 9>-
    fi

    if [ $new_file_to_process == "yes" ]; then
        # Files are now in the work dir ... ready to be processed

        # Run the job as a subprocess passing all variables
        source ./run_job.sh 
    else
        echo '// Sleeping 60 Seconds'
        sleep 60
    fi
done
