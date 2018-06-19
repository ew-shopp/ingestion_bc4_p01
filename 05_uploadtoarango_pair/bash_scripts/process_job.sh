#!/bin/bash
# arg1: work_path
# arg2: code directory
# arg3: input directory
# arg4: work directory
# arg5: output directory
# arg6: docker container id of the Arango DB
# arg7: name of the value collection (must exist)
# arg8: name of the edge collection (must exist)


work_path=${1}
code_directory=${2}
input_directory=${3}
work_directory=${4}
output_directory=${5}
container_id=${6}
collection_value_name=${7}
collection_edge_name=${8}


container_id

echo "work_path: ${work_path}"
echo "code_directory: ${code_directory}"
#echo "input_directory: ${input_directory}"
echo "work_directory: ${work_directory}"
echo "output_directory: ${output_directory}"
echo "container_id: ${container_id}"
echo "collection_value_name: ${collection_value_name}"
echo "collection_edge_name: ${collection_edge_name}"
echo '***'

echo '#'
echo '#  Starting Process: Upload to Arango'
echo '#'

# Construct Paths
work_path_edge=${work_path/_value.json/_edge.json}
file_name_edge=${work_path_edge##*/}

docker ps

## Process the value file to the value collection
#"${code_directory}/process_job_value.sh" "$@"
#
## Find and process the matching edge file to the edge collection
## Call script to find a file and process it 
#"${code_directory}/fetch_one_and_process.sh" "${file_name_edge}" "${code_directory}/process_job_edge.sh" "$@"


echo '   Done'


