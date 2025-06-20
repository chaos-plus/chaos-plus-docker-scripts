#!/bin/bash -e



docker exec -it mysql7 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS nacos DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"


docker exec -it mysql8 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS nacos DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"

sudo mkdir -p ${DATA}/nacos/
sudo chmod 777 ${DATA}/nacos/

if [ f "./custom.properties" ]; then
    sudo \cp -rf custom.properties ${DATA}/nacos/
fi