#!/bin/bash

basedir=/home/volker/TmpEW/toarango
indir=${basedir}/in
outdir=${basedir}/out
workdir=${basedir}/work

DOCKER_RUN="docker run \
    --user `id --user`:`id --group` \
    --cpus 1 \
    --volume ${indir}:/in \
    --volume ${workdir}:/work \
    --volume ${outdir}:/out"

${DOCKER_RUN} toarango /in /work /out
