#!/bin/bash -e


sudo mkdir -p ${DATA}/nginx
sudo chmod -R 777 ${DATA}/nginx


SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo \cp ${SRC_DIR}/nginx.conf ${DATA}/nginx/nginx.conf

export NGINX_CONFIG_HASH=$(md5sum ${DATA}/nginx/nginx.conf | cut -d' ' -f1)