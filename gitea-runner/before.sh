#!/bin/bash -e

sudo mkdir -p ${DATA}/gitea-runner/
sudo chmod 777 ${DATA}/gitea-runner


if [ -z "${REGISTRATION_TOKEN}" ]; then
    echo "REGISTRATION_TOKEN is not set"
    exit 1
fi