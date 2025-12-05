#!/bin/bash -e

# docker restart alloy


# 查找服务的实际容器名
get_container_name() {
    local service_name=$1
    # 尝试匹配服务名相关的容器（兼容 compose 和 stack）
    docker ps -a --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

ALLOY_CONTAINER=$(get_container_name "alloy")

if [ -z "$ALLOY_CONTAINER" ]; then
    echo "⚠️ alloy 容器未找到"
    exit 0
fi

echo " restarting alloy container: $ALLOY_CONTAINER"
docker restart "$ALLOY_CONTAINER"

