#!/bin/bash -e

# 查找服务的实际容器名
get_container_name() {
    local service_name=$1
    # 尝试匹配服务名相关的容器（兼容 compose 和 stack）
    docker ps -a --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

CRONIC_CONTAINER=$(get_container_name "cronic")

if [ -z "$CRONIC_CONTAINER" ]; then
    echo "⚠️ cronic 容器未找到"
    exit 0
fi

docker restart $CRONIC_CONTAINER

