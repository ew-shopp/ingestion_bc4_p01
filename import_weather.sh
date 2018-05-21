containerID=$1
collectionName="weather-2017-germany-separate"
importFolder="/bigdata/steffen/run_bc4_p01/test/in"
pwd
while true
do
	files=(*.json)
	if [ ${#files[@]} -gt 0 ] && [ "${files}" != "*.json" ];
	then 
		echo "File found!"
		filename=$(basename "${files[0]}")
		echo "Importing value collection $filename ..."
		echo "Executing: mv ${importFolder}/${filename} ${importFolder}/imported/"
		mv ${importFolder}/${filename} ${importFolder}/imported/ &&
		echo "Executing: docker cp ${importFolder}/imported/${filename} ${containerID}:./" &&
		docker cp ${importFolder}/imported/${filename} ${containerID}:./ &&
		docker exec -i ${containerID} arangoimp --server.password --file ${filename} --collection ${collectionName} --log.level fatal --threads 6 --batch-size 32768 &&
		docker exec ${containerID} rm ${filename}
		sleep 5
	else
		echo "Waiting for files..."
		sleep 5
	fi
done
