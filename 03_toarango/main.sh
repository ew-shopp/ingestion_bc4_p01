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

ls -lisa /code/Datagraft-RDF-to-Arango-DB

echo '***'

ls -lisa /in/

echo ''
echo '#'
echo '#'
echo '#'
echo ''

while true; do
    nfiles=`find ${input_directory} -name "*.csv" | wc -l`
    if [ "${nfiles}" -gt "0" ]; then

        # Extract File Name
        input_path=`find ${input_directory} -name "*.csv" | head -1`
        echo "// Found ${nfiles} Files"
        echo "   Processing ${input_path}"

        # Construct Paths
        file_name=${input_path##*/}
        file_name_no_ext=${file_name%.*}
        work_path=${work_directory}/${file_name}
        file_name_transformed="${file_name_no_ext}-transformed.csv"
        work_path_results=${work_directory}/results

        # Debug: Show Paths
        echo "!! file_name", ${file_name}
        echo "!! file_name_no_ext", ${file_name_no_ext}
        echo "!! file_name_rdf", ${file_name_rdf}
        echo "!! work_path", ${work_path}
        echo "!! work_path_results", ${work_path_results}
        echo "!! output_directory", ${output_directory}

        # Move to Workspace
        echo "   Moving to Workspace, Making Results Directory"
        mv ${input_path} ${work_directory}
        mkdir -p ${work_path_results}

        # Transforming
        echo "   Transforming to Arango Graph"
        cd ${work_directory}
        node \
            /code/Datagraft-RDF-to-Arango-DB/transformscript.js \
            -t /code/transformation-new.json \
            -f ${work_path}

        # Move Results to Output
        echo "   Moving To Output"
        mv ${work_path_results}/* ${output_directory}

    else
        # Wait
        echo '// Sleeping 60 Seconds'
        sleep 60
    fi
done
