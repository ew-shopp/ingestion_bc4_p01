#!/bin/bash

# arg1: input directory
# arg2: work directory
# arg3: output directory

# while true; do
#     files=(${input-dir}/*.csv)
#     if [ ${#files[@]} -gt 0 ];
#     then 
#         echo "File found!"
#         echo "Transforming file "${files[0]}
#         filename=$(basename "${files[0]}")
#         transformedFileName=$(basename "${files[0]}" .csv)"-transformed.csv"
#         echo "Transforming $filename ..."
#         mv ${files[0]} ../transformed-inputs &&
#         java -Xmx4g -jar transformation-csv3.jar ../transformed-inputs/$filename $transformedFileName
#     else
#         echo "Waiting for files..."
#         sleep 5
#     fi
# done

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

while true; do
    nfiles=`find ${input_directory} -name "*.zip" | wc -l`
    if [ "${nfiles}" -gt "0" ]; then

        # Extract File Name
        input_path=`find ${input_directory} -name "*.zip" | head -1`
        echo "// Found ${nfiles} Files"
        echo "   Processing ${input_path}"

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

        # Move Zip to Workspace
        echo "   Moving Zip to Workspace"
        mv ${input_path} ${work_directory}

        # Extract Zip
        echo "   Extracting without folder structure"
        unzip -j ${work_path} -d ${extract_directory}

        # Move Extracted Zip to Output
        echo "   Moving To Output"
        # mv ${extract_directory} ${output_directory}
        mv ${extract_directory}/* ${output_directory}
        echo 'a'

    else
        # Wait
        echo '// Sleeping 60 Seconds'
        sleep 60
    fi
done
