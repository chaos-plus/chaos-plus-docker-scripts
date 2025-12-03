#!/bin/bash -e

# 查找服务的实际容器名
get_container_name() {
    local service_name=$1
    docker ps -a --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

sudo mkdir -p ${DATA}/nacos
sudo chmod -R 777 ${DATA}/nacos/


sudo wget ${GHPROXY}https://raw.githubusercontent.com/alibaba/nacos/refs/heads/master/distribution/conf/mysql-schema.sql -O ${DATA}/nacos/mysql-schema.sql

sudo sed -i '/^CREATE TABLE[^;]*$/I{/IF NOT EXISTS/I!s/CREATE TABLE/CREATE TABLE IF NOT EXISTS/}' ${DATA}/nacos/mysql-schema.sql

sudo cat ${DATA}/nacos/mysql-schema.sql

MYSQL7_CONTAINER=$(get_container_name "mysql7")
MYSQL8_CONTAINER=$(get_container_name "mysql8")

if [ -n "$MYSQL7_CONTAINER" ]; then
    sudo docker exec -i "$MYSQL7_CONTAINER" mysql -uroot -p${PASSWORD} \
        -e "CREATE DATABASE IF NOT EXISTS nacos DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
    sudo docker exec -i "$MYSQL7_CONTAINER" mysql -uroot -p${PASSWORD} nacos < ${DATA}/nacos/mysql-schema.sql
fi

if [ -n "$MYSQL8_CONTAINER" ]; then
    sudo docker exec -i "$MYSQL8_CONTAINER" mysql -uroot -p${PASSWORD} \
        -e "CREATE DATABASE IF NOT EXISTS nacos DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
    sudo docker exec -i "$MYSQL8_CONTAINER" mysql -uroot -p${PASSWORD} nacos < ${DATA}/nacos/mysql-schema.sql
fi

sudo mkdir -p ${DATA}/nacos
sudo chmod -R 777 ${DATA}/nacos/



export NACOS_AUTH_ENABLE=true
export NACOS_AUTH_TOKEN=$(echo -n '${PASSWORD}${PASSWORD}${PASSWORD}${PASSWORD}${PASSWORD}' | base64) 
export NACOS_AUTH_IDENTITY_KEY=admin
export NACOS_AUTH_IDENTITY_VALUE=${PASSWORD}
