#!/bin/bash -e

# 查找 mysql7 服务的实际容器名
get_container_name() {
    local service_name=$1
    docker ps -a --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

MYSQL7_CONTAINER=$(get_container_name "mysql7")

if [ -z "$MYSQL7_CONTAINER" ]; then
    echo "⚠️ mysql7 容器未找到，跳过健康检查"
    exit 0
fi

until docker exec "$MYSQL7_CONTAINER" mysqladmin ping -uroot -p${PASSWORD} --silent; do
  echo "⏳ Waiting for MySQL 7 to be ready..."
  sleep 2
done

echo "✅ MySQL 7 is ready!"