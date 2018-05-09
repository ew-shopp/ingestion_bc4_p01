#!/bin/bash
# arg1: tmp file              
# arg2: input directory
# arg3: work directory
# arg4: output directory
# arg5: docker container id of the Arango DB
# arg6: name of the value collection (must exist)
# arg7: name of the edge collection (must exist)

tmp_file=${1}
input_directory=${2}
work_directory=${3}
output_directory=${4}
container_id=${5}
collection_value_name=${6}
collection_edge_name=${7}

echo ${tmp_file}
echo ${input_directory}
echo ${work_directory}
echo ${output_directory}
echo ${container_id}
echo ${collection_value_name}
echo ${collection_edge_name}
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
        nfiles=`find ${input_directory} -name "*value*.json" | wc -l`
        if [ "${nfiles}" -gt "0" ]; then
                
            # Extract File Name in random pos
            file_num=`shuf -i1-${nfiles} -n1`
            input_path_value=`find ${input_directory} -name "*value*.json" | head -${file_num} | tail -1`
            input_path_edge=${input_path_value/_value.json/_edge.json}
            echo "// Found ${nfiles} Files"
            echo "// Picking file_num ${file_num}"
            echo "// Processing 1 ${input_path_value}"
            echo "// Processing 2 ${input_path_edge}"

            # Construct Paths
            file_name_value=${input_path_value##*/}
            file_name_edge=${input_path_edge##*/}
            file_name_value_no_ext=${file_name_value%.*}
            file_name_edge_no_ext=${file_name_edge%.*}
            work_path_value=${work_directory}/${file_name_value}
            work_path_edge=${work_directory}/${file_name_edge}
            input_path_value_renamed=${input_path_value}.inmove
            input_path_edge_renamed=${input_path_edge}.inmove

            # Debug: Show Paths
            echo "!! file_name_value", ${file_name_value}
            echo "!! file_name_edge", ${file_name_edge}
            echo "!! file_name_value_no_ext", ${file_name_value_no_ext}
            echo "!! file_name_edge_no_ext", ${file_name_edge_no_ext}
            echo "!! work_path_value", ${work_path_value}
            echo "!! work_path_edge", ${work_path_edge}
                
            # Check if file already there
            #ls -l ${input_directory}
            #ls -l ${work_directory}
            found_existing=`find ${work_directory} -name ${file_name_value} | wc -l`
            echo $found_existing
            if [ "${found_existing}" -eq "0" ]; then

                # Move to Workspace
                echo "   Renaming files"
                echo ${input_path_value}
                echo ${input_path_value_renamed}
                echo ${input_path_edge}
                echo ${input_path_value_edge}
                mv ${input_path_value} ${input_path_value_renamed}
                mv ${input_path_edge} ${input_path_value_edge}
                new_file_to_process="yes"

            else
                echo "// File ${file_name_value} already exists in working dir ... skipping operation"
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
        echo ${input_path_value_renamed}
        echo ${work_path_value}
        mv ${input_path_value_renamed} ${work_path_value}
        echo ${input_path_edge_renamed}
        echo ${work_path_edge}
        mv ${input_path_edge_renamed} ${work_path_edge}

        # Files are now in the work dir ... ready to be processed

        # Run the job as a subprocess passing all variables
        source /code/run_job.sh 
    else
        echo '// Sleeping 60 Seconds'
        sleep 60
    fi
done

