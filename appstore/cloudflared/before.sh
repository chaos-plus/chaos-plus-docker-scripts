#!/bin/bash -e



if [ -z "${CLOUDFLARED_TOKEN}" ]; then
    echo "❌ 错误: CLOUDFLARED_TOKEN 环境变量未设置"
    exit 1
fi