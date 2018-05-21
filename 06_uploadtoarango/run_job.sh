#!/bin/bash

echo '#'
echo '#  Starting Job: Upload to Arango'
echo '#'
# Debug: Show Paths
echo "!! work_path", ${work_path}
echo "!! file_name", ${file_name}

# TODO Where shall these come from
echo "!! container_id", ${container_id}
echo "!! collection_name", ${collection_name}


# Files are now in the work dir ... ready to be processed

# Make imported dir if not there
mkdir -p ${work_directory}/imported

# Uploading
echo "   Uploading collection"

echo "   Executing: docker cp ${work_path} ${container_id}:./" 
docker cp ${work_path} ${container_id}:./  &&
docker exec -i ${container_id} arangoimp --server.password --file ${file_name} --collection ${collection} --log.level fatal --threads 6 --batch-size 32768 &&
docker exec ${container_id} rm ${file_name}  &&

mv ${work_path} ${work_directory}/imported &&

echo '   Done'

