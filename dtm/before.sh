#!/bin/bash -e

# 查找服务的实际容器名
get_container_name() {
    local service_name=$1
    docker ps --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

sudo mkdir -p ${DATA}/dtm
sudo chmod -R 777 ${DATA}/dtm/


sudo wget https://raw.githubusercontent.com/dtm-labs/dtm/refs/heads/main/sqls/dtmsvr.storage.mysql.sql -O ${DATA}/dtm/dtmsvr.storage.mysql.sql
sudo wget https://raw.githubusercontent.com/dtm-labs/dtm/refs/heads/main/sqls/dtmcli.barrier.mysql.sql -O ${DATA}/dtm/dtmcli.barrier.mysql.sql
sudo wget https://raw.githubusercontent.com/dtm-labs/dtm/refs/heads/main/sqls/busi.mysql.sql -O ${DATA}/dtm/busi.mysql.sql

sudo sed -i '/^CREATE TABLE[^;]*$/I{/IF NOT EXISTS/I!s/CREATE TABLE/CREATE TABLE IF NOT EXISTS/}' ${DATA}/dtm/dtmsvr.storage.mysql.sql
sudo sed -i '/^CREATE TABLE[^;]*$/I{/IF NOT EXISTS/I!s/CREATE TABLE/CREATE TABLE IF NOT EXISTS/}' ${DATA}/dtm/dtmcli.barrier.mysql.sql
sudo sed -i '/^CREATE TABLE[^;]*$/I{/IF NOT EXISTS/I!s/CREATE TABLE/CREATE TABLE IF NOT EXISTS/}' ${DATA}/dtm/busi.mysql.sql

sudo cat ${DATA}/dtm/dtmsvr.storage.mysql.sql
sudo cat ${DATA}/dtm/dtmcli.barrier.mysql.sql
sudo cat ${DATA}/dtm/busi.mysql.sql

MYSQL7_CONTAINER=$(get_container_name "mysql7")
MYSQL8_CONTAINER=$(get_container_name "mysql8")

if [ -n "$MYSQL7_CONTAINER" ]; then
    sudo docker exec -i "$MYSQL7_CONTAINER" mysql -uroot -p${PASSWORD} \
        -e "CREATE DATABASE IF NOT EXISTS dtm DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
    sudo docker exec -i "$MYSQL7_CONTAINER" mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/dtmsvr.storage.mysql.sql
    sudo docker exec -i "$MYSQL7_CONTAINER" mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/dtmcli.barrier.mysql.sql
    sudo docker exec -i "$MYSQL7_CONTAINER" mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/busi.mysql.sql
fi

if [ -n "$MYSQL8_CONTAINER" ]; then
    sudo docker exec -i "$MYSQL8_CONTAINER" mysql -uroot -p${PASSWORD} \
        -e "CREATE DATABASE IF NOT EXISTS dtm DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
    sudo docker exec -i "$MYSQL8_CONTAINER" mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/dtmsvr.storage.mysql.sql
    sudo docker exec -i "$MYSQL8_CONTAINER" mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/dtmcli.barrier.mysql.sql
    sudo docker exec -i "$MYSQL8_CONTAINER" mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/busi.mysql.sql
fi

sudo mkdir -p ${DATA}/dtm
sudo chmod -R 777 ${DATA}/dtm/



