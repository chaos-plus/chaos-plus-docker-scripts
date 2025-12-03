#!/bin/bash -e

# 查找服务的实际容器名
get_container_name() {
    local service_name=$1
    docker ps -a --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

MYSQL7_CONTAINER=$(get_container_name "mysql7")
MYSQL8_CONTAINER=$(get_container_name "mysql8")

if [ -n "$MYSQL7_CONTAINER" ]; then
    docker exec -i "$MYSQL7_CONTAINER" mysql -uroot -p${PASSWORD} \
        -e "CREATE DATABASE IF NOT EXISTS waline DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
fi

if [ -n "$MYSQL8_CONTAINER" ]; then
    docker exec -i "$MYSQL8_CONTAINER" mysql -uroot -p${PASSWORD} \
        -e "CREATE DATABASE IF NOT EXISTS waline DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
fi
