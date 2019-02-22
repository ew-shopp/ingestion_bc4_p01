#!/bin/bash
# arg1: work_path
# arg2: code directory
# arg3: input directory
# arg4: work directory
# arg5: output directory
# arg6: json transformation description name with full path

work_path=${1}
code_directory=${2}
input_directory=${3}
work_directory=${4}
output_directory=${5}
transformation_json_full_path=${6}

echo "work_path: ${work_path}"
echo "code_directory: ${code_directory}"
#echo "input_directory: ${input_directory}"
echo "work_directory: ${work_directory}"
echo "output_directory: ${output_directory}"
echo "transformation_json_full_path: ${transformation_json_full_path}"
echo '***'

echo '#'
echo '#  Starting Process: Toarango'
echo '#'


# Construct Paths
file_name=${work_path##*/}
file_name_no_ext=${file_name%.*}
work_path_results=${work_directory}/results

echo "!! work_path_results", ${work_path_results}

# Files are now in the work dir ... ready to be processed

# Making Results Directory
mkdir -p ${work_path_results}

# Transforming
echo "   Transforming to Arango Graph"
cd ${work_directory}
node \
    /code/Datagraft-RDF-to-Arango-DB/transformscript.js \
    -t ${transformation_json_full_path} \
    -f ${work_path}

# Move the files to output
${code_directory}/move_to_output.sh ${code_directory} ${output_directory} ${work_path_results}/${file_name_no_ext}*

echo '   Done'


