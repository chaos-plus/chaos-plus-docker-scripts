#!/bin/bash -e



docker exec -it mysql7 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS waline DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"

docker exec -it mysql8 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS waline DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
