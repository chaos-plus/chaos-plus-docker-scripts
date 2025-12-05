#!/bin/bash -e


if [ -z "${PASSWORD}" ]; then
    echo "PASSWORD is empty"
    exit 1
fi

################################################
## MySQL
################################################
if [ -d "${DATA}/mysql7" ]; then
    echo "mysql7 data exists, skip"
else
    echo "mysql7 data lost, create"
    
    sudo mkdir -p ${DATA}/mysql7/data
    sudo mkdir -p ${DATA}/mysql7/conf
    
    # sudo mkdir -p ${DATA}/mysql7/conf/conf.d
    # sudo mkdir -p ${DATA}/mysql7/conf/mysql.conf.d

    sudo chmod -R 777 ${DATA}/mysql7/

    sudo cp ./*.cnf ${DATA}/mysql7/conf/

    sudo chmod -R 777 ${DATA}/mysql7
    sudo chmod -R 644 ${DATA}/mysql7/conf/*
fi
################################################
