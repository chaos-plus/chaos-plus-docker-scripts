#!/bin/bash -e


if [ -z "${PASSWORD:-}" ]; then
    echo "PASSWORD is empty"
    exit 1
fi

sudo mkdir -p ${DATA}/debezium
sudo chmod -R 777 ${DATA}/debezium

