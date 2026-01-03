#!/bin/bash -e



# export OSS_ENDPOINT="oss-ap-southeast-3.aliyuncs.com"
# export OSS_REGION="ap-southeast-3"
# export OSS_BUCKET="loki-data"
# export OSS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
# export OSS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"

if [ -z "${OSS_ENDPOINT:-}" ] || [ -z "${OSS_REGION:-}" ] || [ -z "${OSS_BUCKET:-}" ] || [ -z "${OSS_ACCESS_KEY_ID:-}" ] || [ -z "${OSS_SECRET_ACCESS_KEY:-}" ]; then
    echo "OSS_ENDPOINT, OSS_REGION, OSS_BUCKET, OSS_ACCESS_KEY_ID, OSS_SECRET_ACCESS_KEY must be set"
    exit 1
fi



# 配置用户名和密码（可以从环境变量读取，也可以自动生成随机密码）
REGISTRY_USER=${REGISTRY_USER:-admin}
REGISTRY_PASSWORD=${REGISTRY_PASSWORD:-${PASSWORD:-$(openssl rand -base64 16)}}

# 创建 registry 目录
sudo mkdir -p ${DATA}/registry/
sudo chmod -R 777 ${DATA}/registry/

# 生成 htpasswd 文件（Bcrypt 加密）
docker run --rm --entrypoint htpasswd httpd:2 -Bbn "$REGISTRY_USER" "$REGISTRY_PASSWORD" > ${DATA}/registry/htpasswd

echo "htpasswd file generated at ${DATA}/registry/htpasswd"
