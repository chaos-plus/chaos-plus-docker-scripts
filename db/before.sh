#!/bin/bash -e


################################################
## MySQL
################################################
if [ -d "${DATA}/mysql" ]; then
    echo "mysql data exists, skip"
else
    echo "mysql data lost, create"
    
    sudo mkdir -p ${DATA}/mysql/data
    sudo mkdir -p ${DATA}/mysql/conf
    
    # sudo mkdir -p ${DATA}/mysql/conf/conf.d
    # sudo mkdir -p ${DATA}/mysql/conf/mysql.conf.d

    sudo chmod -R 777 ${DATA}/mysql/

    sudo cp ./*.cnf ${DATA}/mysql/conf/

    sudo chmod -R 777 ${DATA}/mysql
    sudo chmod -R 644 ${DATA}/mysql/conf/*
fi
################################################
