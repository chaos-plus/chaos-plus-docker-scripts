#!/bin/bash -e

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

sudo docker exec -i mysql7 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS dtm DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
sudo docker exec -i mysql7 mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/dtmsvr.storage.mysql.sql
sudo docker exec -i mysql7 mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/dtmcli.barrier.mysql.sql
sudo docker exec -i mysql7 mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/busi.mysql.sql

sudo docker exec -i mysql8 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS dtm DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
sudo docker exec -i mysql8 mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/dtmsvr.storage.mysql.sql
sudo docker exec -i mysql8 mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/dtmcli.barrier.mysql.sql
sudo docker exec -i mysql8 mysql -uroot -p${PASSWORD} dtm < ${DATA}/dtm/busi.mysql.sql

sudo mkdir -p ${DATA}/dtm
sudo chmod -R 777 ${DATA}/dtm/



