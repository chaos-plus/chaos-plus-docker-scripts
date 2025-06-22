#!/bin/bash -e


sudo mkdir -p ${DATA}/nacos
sudo chmod -R 777 ${DATA}/nacos/


sudo wget https://raw.githubusercontent.com/alibaba/nacos/refs/heads/master/distribution/conf/mysql-schema.sql -O ${DATA}/nacos/mysql-schema.sql

sudo sed -i '/^CREATE TABLE[^;]*$/I{/IF NOT EXISTS/I!s/CREATE TABLE/CREATE TABLE IF NOT EXISTS/}' ${DATA}/nacos/mysql-schema.sql

cat ${DATA}/nacos/mysql-schema.sql

docker exec -i mysql7 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS nacos DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
sudo docker exec -i mysql7 mysql -uroot -p${PASSWORD} nacos < ${DATA}/nacos/mysql-schema.sql

docker exec -i mysql8 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS nacos DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"

sudo docker exec -i mysql8 mysql -uroot -p${PASSWORD} nacos < ${DATA}/nacos/mysql-schema.sql

sudo mkdir -p ${DATA}/nacos
sudo chmod -R 777 ${DATA}/nacos/



export NACOS_AUTH_ENABLE=true
export NACOS_AUTH_TOKEN=$(echo -n '${PASSWORD}${PASSWORD}${PASSWORD}${PASSWORD}${PASSWORD}' | base64) 
export NACOS_AUTH_IDENTITY_KEY=admin
export NACOS_AUTH_IDENTITY_VALUE=${PASSWORD}
