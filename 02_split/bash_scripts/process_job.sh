#!/bin/bash
# arg1: work_path
# arg2: code directory
# arg3: input directory
# arg4: work directory
# arg5: output directory
# arg6 ... : application params

work_path=${1}
code_directory=${2}
input_directory=${3}
work_directory=${4}
output_directory=${5}

echo "work_path: ${work_path}"
echo "code_directory: ${code_directory}"
#echo "input_directory: ${input_directory}"
echo "work_directory: ${work_directory}"
echo "output_directory: ${output_directory}"
echo '***'

echo '#'
echo '#  Starting Process: Split'
echo '#'


# Construct Paths
file_name=${work_path##*/}
file_name_no_ext=${file_name%.*}
extract_directory=${work_directory}/${file_name_no_ext}

split_file_suffix="${work_directory}/${file_name_no_ext}/${file_name_no_ext}-"

# Debug: Show Paths
echo "!! work_path", ${work_path}
echo "!! extract_directory", ${extract_directory}
echo "!! split_file_suffix", ${split_file_suffix}

# Files are now in the work dir ... ready to be processed

# Split files
mkdir ${extract_directory}

echo "   Split file int work directory"
split -l 800000 --additional-suffix=.csv ${work_path}  ${split_file_suffix}

# Move the files to output
${code_directory}/move_to_output.sh ${output_directory} ${extract_directory}/*

# Cleanup
rm -rf $extract_directory

echo '   Done'


