#!/bin/bash

basedir=/bigdata/volker/TmpEW/transform
indir=${basedir}/in
outdir=${basedir}/out
workdir=${basedir}/work

DOCKER_SERVICE="docker service create \
    --name ewshopp-ingestion-02-transform \
    --replicas 1 \
    --user `id --user`:`id --group` \
    --detach \
    --limit-cpu 1 \
    --mount type=bind,source=${indir},destination=/in \
    --mount type=bind,source=${workdir},destination=/work \
    --mount type=bind,source=${outdir},destination=/out"

${DOCKER_SERVICE} transform /in /work /out
