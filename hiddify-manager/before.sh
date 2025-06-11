#!/bin/bash -e

while ! docker exec -it mysql mysqladmin -uroot -p${PASSWORD} ping 2>/dev/null; do
    echo "wait mysql ready ... ..."
    sleep 1
done


docker exec -it mysql mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS hiddifypanel DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
