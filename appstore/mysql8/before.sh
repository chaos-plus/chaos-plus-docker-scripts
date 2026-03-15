#!/bin/bash -e


if [ -z "${PASSWORD:-}" ]; then
    echo "PASSWORD is empty"
    exit 1
fi

################################################
## MySQL
################################################
sudo mkdir -p ${DATA}/mysql8/data
sudo mkdir -p ${DATA}/mysql8/log
sudo chmod -R 777 ${DATA}/mysql8/

# 创建 Docker config（每次都需要导出变量）
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo mkdir -p ${DATA}/mysql8
sudo \cp -rf ${SRC_DIR}/my.cnf ${DATA}/mysql8/my.cnf
sudo chmod 644 ${DATA}/mysql8/my.cnf

export MYSQL8_CONFIG_HASH=$(md5sum ${DATA}/mysql8/my.cnf | cut -d' ' -f1)

sudo chmod -R 777 ${DATA}/mysql8
################################################
