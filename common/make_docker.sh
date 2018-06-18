#!/bin/bash
echo "Working dir: $(pwd)"
echo "Docke image name: $1"
read -p "Press any key to start ..."

mkdir common_scripts
cp ../common/* common_scripts
docker build -t $1 .
docker push $1 

