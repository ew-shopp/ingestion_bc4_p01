#!/bin/bash
# arg1: work_path
# arg2: code directory
# arg3: input directory
# arg4: work directory
# arg5: output directory
# arg6: docker container id of the Arango DB
# arg7: name of the value collection (must exist)
# arg8: name of the edge collection (must exist)


work_path_edge=${1}
code_directory=${2}
input_directory=${3}
work_directory=${4}
output_directory=${5}
container_id=${6}
#collection_value_name=${7}
collection_edge_name=${8}


container_id

echo "work_path_edge: ${work_path_edge}"
echo "code_directory: ${code_directory}"
#echo "input_directory: ${input_directory}"
echo "work_directory: ${work_directory}"
echo "output_directory: ${output_directory}"
echo "container_id: ${container_id}"
#echo "collection_value_name: ${collection_value_name}"
echo "collection_edge_name: ${collection_edge_name}"
echo '***'

echo '#'
echo '#  Starting Process: Upload to Arango - edge'
echo '#'


# Construct Paths
file_name_edge=${work_path_edge##*/}

# File are now in the work dir ... ready to be processed

# Uploading
echo "   Uploading edge collection"

echo "   Executing: docker cp ${work_path_edge} ${container_id}:./" 
docker cp ${work_path_edge} ${container_id}:./  &&
docker exec -i ${container_id} arangoimp --server.password --file ${file_name_edge} --collection ${collection_edge_name} --log.level fatal --threads 6 --batch-size 32768 &&
docker exec ${container_id} rm ${file_name_edge}  &&

# Move the files to output
${code_directory}/move_to_output.sh ${output_directory} ${work_path_edge} &&

sleep 5 &&

echo '   Done edge'


