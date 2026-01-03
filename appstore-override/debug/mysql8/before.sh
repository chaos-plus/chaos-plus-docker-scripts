#!/bin/bash -e

    
sudo mkdir -p ${DATA}/mysql8/data
sudo mkdir -p ${DATA}/mysql8/conf

sudo chmod -R 777 ${DATA}/mysql8/

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo \cp -rf ${SRC_DIR}/*.cnf ${DATA}/mysql8/conf/

sudo chmod -R 777 ${DATA}/mysql8
sudo chmod -R 644 ${DATA}/mysql8/conf/*
