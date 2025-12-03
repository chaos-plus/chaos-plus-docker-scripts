#!/bin/bash -e

sudo mkdir -p ${DATA}/gitea-runner/
sudo chmod 777 ${DATA}/gitea-runner/

sudo rm -rf ${DATA}/gitea-runner/config.yaml
sudo cp config.yaml ${DATA}/gitea-runner/config.yaml


if [ -z "${REGISTRATION_TOKEN}" ]; then
    echo "REGISTRATION_TOKEN is not set"
    exit 1
fi