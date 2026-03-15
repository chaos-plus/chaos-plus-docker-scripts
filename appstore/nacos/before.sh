#!/bin/bash -e

sudo mkdir -p ${DATA}/nacos
sudo mkdir -p ${TEMP}/nacos
sudo chmod -R 777 ${DATA}/nacos/
sudo chmod -R 777 ${TEMP}/nacos/



sudo wget ${GHPROXY:-}https://raw.githubusercontent.com/alibaba/nacos/refs/heads/master/distribution/conf/mysql-schema.sql -O ${DATA}/nacos/mysql-schema.sql

sudo sed -i '/^CREATE TABLE[^;]*$/I{/IF NOT EXISTS/I!s/CREATE TABLE/CREATE TABLE IF NOT EXISTS/}' ${DATA}/nacos/mysql-schema.sql

sudo cat ${DATA}/nacos/mysql-schema.sql


init_db mysql7 3306 root ${PASSWORD:-} nacos
init_db mysql8 3306 root ${PASSWORD:-} nacos

init_sql mysql7 3306 root ${PASSWORD:-} nacos ${DATA}/nacos/mysql-schema.sql
init_sql mysql8 3306 root ${PASSWORD:-} nacos ${DATA}/nacos/mysql-schema.sql

sudo mkdir -p ${DATA}/nacos
sudo mkdir -p ${TEMP}/nacos
sudo chmod -R 777 ${DATA}/nacos/
sudo chmod -R 777 ${TEMP}/nacos/



export NACOS_AUTH_ENABLE=true
export NACOS_AUTH_TOKEN=$(echo -n '${PASSWORD}${PASSWORD}${PASSWORD}${PASSWORD}${PASSWORD}' | base64) 
export NACOS_AUTH_IDENTITY_KEY=admin
export NACOS_AUTH_IDENTITY_VALUE=${PASSWORD:-}
