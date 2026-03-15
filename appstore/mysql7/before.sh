#!/bin/bash -e


if [ -z "${PASSWORD:-}" ]; then
    echo "PASSWORD is empty"
    exit 1
fi

################################################
## MySQL
################################################
if [ -d "${DATA}/mysql7" ]; then
    echo "mysql7 data exists, skip"
else
    echo "mysql7 data lost, create"
    
    sudo mkdir -p ${DATA}/mysql7/data
    sudo mkdir -p ${DATA}/mysql7/log
    sudo chmod -R 777 ${DATA}/mysql7/
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo \cp ${SRC_DIR}/*.cnf ${DATA}/mysql7/
sudo chmod 644 ${DATA}/mysql7/my.cnf

export MYSQL7_CONFIG_HASH=$(md5sum ${DATA}/mysql7/my.cnf | cut -d' ' -f1)

sudo chmod -R 777 ${DATA}/mysql7
################################################
