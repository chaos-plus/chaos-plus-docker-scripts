#!/bin/bash -e


if docker ps -a | grep mysql7; then
docker exec -it mysql7 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS umami DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
fi

if docker ps -a | grep mysql8; then
docker exec -it mysql8 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS umami DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
fi
