#!/bin/bash -e

# 查找 mysql8 服务的实际容器名
get_container_name() {
    local service_name=$1
    # 尝试匹配服务名相关的容器（兼容 compose 和 stack）
    docker ps --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

MYSQL8_CONTAINER=$(get_container_name "mysql8")

if [ -z "$MYSQL8_CONTAINER" ]; then
    echo "⚠️ mysql8 容器未找到，跳过健康检查"
    exit 0
fi

until docker exec "$MYSQL8_CONTAINER" mysqladmin ping -uroot -p${PASSWORD} --silent; do
  echo "⏳ Waiting for MySQL 8 to be ready..."
  sleep 2
done

echo "✅ MySQL 8 is ready!"