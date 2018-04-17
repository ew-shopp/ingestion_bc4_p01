#!/bin/bash

# global
basedir="/home/volker/TmpEW/pipe"
indir_global="${basedir}/in"
outdir_global="${basedir}/out"

# steps
indir_00=${indir_global}
outdir_00="${basedir}/_out00"
workdir_00="${basedir}/_work00"

indir_01=${outdir_00}
outdir_01="${basedir}/_out01"
workdir_01="${basedir}/_work01"

indir_02=${outdir_01}
outdir_02="${basedir}/_out02"
workdir_02="${basedir}/_work02"

indir_03=${outdir_02}
outdir_03=${outdir_global}
workdir_03="${basedir}/_work03"

#
# run_00_unzip
#

DOCKER_RUN="docker run \
    --user `id --user`:`id --group` \
    --volume ${indir_00}:/in \
    --volume ${workdir_00}:/work \
    --volume ${outdir_00}:/out"

${DOCKER_RUN} unzip /in /work /out

#
# run_01_tsv2csv
#

DOCKER_RUN="docker run \
    --user `id --user`:`id --group` \
    --volume ${indir_01}:/in \
    --volume ${workdir_01}:/work \
    --volume ${outdir_01}:/out"

${DOCKER_RUN} tsv2csv /in /work /out

#
# run_02_transform
#

DOCKER_RUN="docker run \
    --user `id --user`:`id --group` \
    --volume ${indir_02}:/in \
    --volume ${workdir_02}:/work \
    --volume ${outdir_02}:/out"

${DOCKER_RUN} transform /in /work /out

#
# run_03_toarango
#

DOCKER_RUN="docker run \
    --user `id --user`:`id --group` \
    --volume ${indir_03}:/in \
    --volume ${workdir_03}:/work \
    --volume ${outdir_03}:/out"

${DOCKER_RUN} toarango /in /work /out
