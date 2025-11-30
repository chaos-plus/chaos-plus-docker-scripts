#!/bin/bash -e

# docker restart loki


# 查找服务的实际容器名
get_container_name() {
    local service_name=$1
    # 尝试匹配服务名相关的容器（兼容 compose 和 stack）
    docker ps --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

LOKI_CONTAINER=$(get_container_name "loki")

if [ -z "$LOKI_CONTAINER" ]; then
    echo "⚠️ loki 容器未找到"
    exit 0
fi

docker restart $LOKI_CONTAINER

