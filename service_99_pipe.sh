#!/bin/bash

# global
basedir="/bigdata/volker/TmpEW/pipe"
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

unzip_image_name="registry.sintef.cloud/unzip-jot-data"
tsv_to_csv_image_name="registry.sintef.cloud/tsv-to-csv"
data_cleaning_image_name="registry.sintef.cloud/clean-using-grafterizer"
transform_to_arango_image_name="registry.sintef.cloud/transform-to-arango"

#
# run_00_unzip
#

DOCKER_SERVICE="docker service create \
    --name ewshopp-ingestion-00-unzip \
    --replicas 1 \
    --user `id --user`:`id --group` \
    --detach \
    --limit-cpu 1 \
    --mount type=bind,source=${indir_00},destination=/in \
    --mount type=bind,source=${workdir_00},destination=/work \
    --mount type=bind,source=${outdir_00},destination=/out"

${DOCKER_SERVICE} ${unzip_image_name} /in /work /out

#
# run_01_tsv2csv
#

DOCKER_SERVICE="docker service create \
    --name ewshopp-ingestion-01-tsv2csv \
    --replicas 1 \
    --user `id --user`:`id --group` \
    --detach \
    --limit-cpu 1 \
    --mount type=bind,source=${indir_01},destination=/in \
    --mount type=bind,source=${workdir_01},destination=/work \
    --mount type=bind,source=${outdir_01},destination=/out"

${DOCKER_SERVICE} ${tsv_to_csv_image_name} /in /work /out

#
# run_02_transform
#

DOCKER_SERVICE="docker service create \
    --name ewshopp-ingestion-02-transform \
    --replicas 1 \
    --user `id --user`:`id --group` \
    --detach \
    --limit-cpu 1 \
    --mount type=bind,source=${indir_02},destination=/in \
    --mount type=bind,source=${workdir_02},destination=/work \
    --mount type=bind,source=${outdir_02},destination=/out"

${DOCKER_SERVICE} ${data_cleaning_image_name} /in /work /out

#
# run_03_toarango
#

DOCKER_SERVICE="docker service create \
    --name ewshopp-ingestion-03-toarango \
    --replicas 1 \
    --user `id --user`:`id --group` \
    --detach \
    --limit-cpu 1 \
    --mount type=bind,source=${indir_03},destination=/in \
    --mount type=bind,source=${workdir_03},destination=/work \
    --mount type=bind,source=${outdir_03},destination=/out"

${DOCKER_SERVICE} ${transform_to_arango_image_name} /in /work /out
