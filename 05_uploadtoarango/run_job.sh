#!/bin/bash

echo '#'
echo '#  Starting Job: Upload to Arango'
echo '#'
# Debug: Show Paths
echo "!! work_path_value", ${work_path_value}
echo "!! work_path_edge", ${work_path_edge}

# TODO Where shall these come from
echo "!! container_id", ${container_id}
echo "!! collection_value_name", ${collection_value_name}
echo "!! collection_edge_name", ${collection_edge_name}


# Files are now in the work dir ... ready to be processed

# Make imported dir if not there
mkdir -p ${work_directory}/imported

# Uploading
echo "   Uploading value collection"

echo "   Executing: docker cp ${work_path_value} ${container_id}:./" 
docker cp ${work_path_value} ${container_id}:./  &&
docker exec -i ${container_id} arangoimp --server.password --file ${filename_value} --collection ${collection_value} --log.level fatal --threads 6 --batch-size 32768 &&
docker exec ${container_id} rm ${filename_value}  &&

mv ${work_path_value} ${work_directory}/imported &&

sleep 5 &&

echo "   Uploading edge collection" &&
echo "   Executing: docker cp ${work_path_edge} ${container_id}:./" 
docker cp ${work_path_edge} ${container_id}:./  &&
docker exec -i ${container_id} arangoimp --server.password --file ${filename_edge} --collection ${collection_edge} --from-collection-prefix ${collection_value} --to-collection-prefix ${collection_value} --log.level fatal --threads 6 --batch-size 32768 &&
docker exec ${container_id} rm ${filename_edge}  &&

mv ${work_path_edge} ${work_directory}/imported &&

echo '   Done'

