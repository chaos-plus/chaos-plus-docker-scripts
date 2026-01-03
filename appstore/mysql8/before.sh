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
export MYSQL8_CONFIG=$(create_versioned_config "mysql8-config" "${SRC_DIR}/my.cnf" 3)

sudo chmod -R 777 ${DATA}/mysql8
################################################
