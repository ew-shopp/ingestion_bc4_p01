#!/bin/bash

basedir=/home/volker/TmpEW/unzip
indir=${basedir}/in
outdir=${basedir}/out
workdir=${basedir}/work

DOCKER_RUN="docker run \
    --user `id --user`:`id --group` \
    --volume ${indir}:/in \
    --volume ${workdir}:/work \
    --volume ${outdir}:/out"

${DOCKER_RUN} unzip /in /work /out
