#!/bin/bash -e

# 查找 mysql7 服务的实际容器名（带重试）
get_container_name() {
    local service_name=$1
    # 尝试匹配服务名相关的容器（兼容 compose 和 stack）
    docker ps --filter "name=${service_name}" --filter "status=running" --format "{{.Names}}" | head -n 1
}

# 等待容器启动（最多重试 30 次，每次 2 秒）
MAX_RETRIES=30
RETRY_COUNT=0
MYSQL7_CONTAINER=""

echo "等待 mysql7 容器启动..."
while [ -z "$MYSQL7_CONTAINER" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    MYSQL7_CONTAINER=$(get_container_name "mysql7")
    if [ -z "$MYSQL7_CONTAINER" ]; then
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "等待容器启动... ($RETRY_COUNT/$MAX_RETRIES)"
        sleep 2
    fi
done

if [ -z "$MYSQL7_CONTAINER" ]; then
    echo "mysql7 容器未找到，跳过健康检查"
    exit 0
fi

echo "找到容器: $MYSQL7_CONTAINER"

# 等待 MySQL 服务就绪
until docker exec "$MYSQL7_CONTAINER" mysqladmin ping -uroot -p"${PASSWORD:-}" --silent 2>/dev/null; do
  echo "Waiting for MySQL 7 to be ready..."
  sleep 2
done

echo "MySQL 7 is ready!"