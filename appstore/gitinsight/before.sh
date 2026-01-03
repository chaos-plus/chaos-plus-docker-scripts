#!/bin/bash -e

mkdir -p ${DATA}/gitinsight
mkdir -p ${TEMP}/gitinsight/.repo
chmod -R 777 ${DATA}/gitinsight
chmod -R 777 ${TEMP}/gitinsight

# if [ ! -f ${DATA}/gitinsight/config.yaml ]; then
#     touch ${DATA}/gitinsight/config.yaml
#     docker run --rm \
#         -v ${DATA}/gitinsight/config.yaml:/app/config.yaml \
#         ghcr.io/robotism/gitinsight:latest \
#         ./gitinsight config gen -f /app/config.yaml
# fi
