#!/bin/bash -e


# docker exec -it mysql mysql -uroot -p${PASSWORD} \
#     -e "CREATE DATABASE IF NOT EXISTS hiddifypanel DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"


bash <(curl -Ls https://raw.githubusercontent.com/xeefei/3x-ui/master/install.sh)