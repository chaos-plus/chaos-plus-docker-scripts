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

# 创建 Docker config（每次都需要导出变量）
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export MYSQL7_CONFIG=$(create_versioned_config "mysql7-config" "${SRC_DIR}/my.cnf" 3)

sudo chmod -R 777 ${DATA}/mysql7
################################################
