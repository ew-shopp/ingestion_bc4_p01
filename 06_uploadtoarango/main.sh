#!/bin/bash
# arg1: tmp file              
# arg2: input directory
# arg3: work directory
# arg4: output directory
# arg5: docker container id of the Arango DB
# arg6: name of the collection (must exist)

tmp_file=${1}
input_directory=${2}
work_directory=${3}
output_directory=${4}
container_id=${5}
collection_name=${6}

echo ${tmp_file}
echo ${input_directory}
echo ${work_directory}
echo ${output_directory}
echo ${container_id}
echo ${collection_name}
echo '***'

echo '#'
echo '#   Starting: Main'
echo '#'


lock_file="${input_directory}/dir_rw.lock"

while [ -f $tmp_file ]; do
    new_file_to_process="no"

    # Aquire lock
    exec 9>$lock_file
    # if flock -n 9; then   # No wait
    echo "// Aquire lock ${lock_file}"
    if flock 9; then
        
        # Check if there are files to process
        nfiles=`find ${input_directory} -name "*.json" | wc -l`
        if [ "${nfiles}" -gt "0" ]; then
                
            # Extract File Name in random pos
            file_num=`shuf -i1-${nfiles} -n1`
            input_path=`find ${input_directory} -name "*.json" | head -${file_num} | tail -1`
            echo "// Found ${nfiles} Files"
            echo "// Picking file_num ${file_num}"
            echo "// Processing 1 ${input_path}"

            # Construct Paths
            file_name=${input_path##*/}
            file_name_no_ext=${file_name%.*}
            work_path=${work_directory}/${file_name}
            input_path_renamed=${input_path}.inmove

            # Debug: Show Paths
            echo "!! file_name", ${file_name}
            echo "!! file_name_no_ext", ${file_name_no_ext}
            echo "!! work_path", ${work_path}
                
            # Check if file already there
            #ls -l ${input_directory}
            #ls -l ${work_directory}
            found_existing=`find ${work_directory} -name ${file_name} | wc -l`
            echo $found_existing
            if [ "${found_existing}" -eq "0" ]; then

                # Move to Workspace
                echo "   Renaming files"
                echo ${input_path}
                echo ${input_path_renamed}
                mv ${input_path} ${input_path_renamed}
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
        # Move renamed file to Workspace
        echo "   Moving to Workspace"
        echo ${input_path_renamed}
        echo ${work_path}
        mv ${input_path_renamed} ${work_path}

        # Files are now in the work dir ... ready to be processed

        # Run the job as a subprocess passing all variables
        source /code/run_job.sh 
    else
        echo '// Sleeping 60 Seconds'
        sleep 60
    fi
done

