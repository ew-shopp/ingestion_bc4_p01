.PHONY: build_unzip build_tsv2csv build_transform build_toarango nuke

# build_all
build_all: build_unzip build_tsv2csv build_transform build_toarango

# build_unzip
build_unzip:
	docker build --tag unzip ./00_unzip

build_tsv2csv:
	docker build --tag tsv2csv ./01_tsv2csv

build_transform:
	docker build --tag transform ./02_transform

build_toarango:
	docker build --tag toarango ./03_toarango

# Be careful, this nukes all containers and images on the machine!
nuke:
	docker rm $(shell docker ps -aq)
	docker rmi $(shell docker images -q)
