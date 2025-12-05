#!/bin/bash -e


if [ -z "${PASSWORD}" ]; then
    echo "PASSWORD is empty"
    exit 1
fi

################################################
## MySQL
################################################
if [ -d "${DATA}/mysql8" ]; then
    echo "mysql8 data exists, skip"
else
    echo "mysql8 data lost, create"
    
    sudo mkdir -p ${DATA}/mysql8/data
    sudo mkdir -p ${DATA}/mysql8/conf
    
    # sudo mkdir -p ${DATA}/mysql8/conf/conf.d
    # sudo mkdir -p ${DATA}/mysql8/conf/mysql.conf.d

    sudo chmod -R 777 ${DATA}/mysql8/

    sudo cp ./*.cnf ${DATA}/mysql8/conf/

    sudo chmod -R 777 ${DATA}/mysql8
    sudo chmod -R 644 ${DATA}/mysql8/conf/*
fi
################################################
