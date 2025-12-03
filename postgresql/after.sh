#!/bin/bash

echo "⏳ Waiting for PostgreSQL to be ready..."

# 查找 postgresql 服务的实际容器名
get_container_name() {
    local service_name=$1
    docker ps -a --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

POSTGRESQL_CONTAINER=$(get_container_name "postgresql")

if [ -z "$POSTGRESQL_CONTAINER" ]; then
    echo "⚠️ postgresql 容器未找到，跳过健康检查"
    exit 0
fi

until docker exec "$POSTGRESQL_CONTAINER" psql -U root -d postgres -c "SELECT 1" &>/dev/null; do
  echo "⏳ Waiting for PostgreSQL..."
  sleep 2
done

echo "✅ PostgreSQL is ready!"
