#!/bin/bash
# arg1: info_string              

info_string=${1}

# Get date info in readable format and epoch
date_string=$(date '+%c, %s.%N')

# Append date string to log file with info text
echo "####DATE_ENTRY####, ${date_string}, ${info_string}"

