#!/bin/bash -e



if [ -z "${CLOUDFLARED_TOKEN:-}" ]; then
    echo "❌ 错误: CLOUDFLARED_TOKEN 环境变量未设置"
    exit 1
fi

sudo mkdir -p ${DATA}/cloudflared

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo \cp -rf ${SRC_DIR}/cf_monitor.sh ${DATA}/cloudflared/cf_monitor.sh
export CLOUDFLARED_CONFIG_HASH=$(md5sum ${DATA}/cloudflared/cf_monitor.sh | cut -d' ' -f1)
