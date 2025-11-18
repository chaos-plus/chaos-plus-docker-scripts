#!/bin/bash -e

sleep 10

# 查找 alist 服务的实际容器名
get_container_name() {
    local service_name=$1
    docker ps --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

ALIST_CONTAINER=$(get_container_name "alist")

if [ -n "$ALIST_CONTAINER" ]; then
    docker exec -it "$ALIST_CONTAINER" ./alist admin set ${PASSWORD} || true
fi