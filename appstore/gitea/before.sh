#!/bin/bash -e

sudo mkdir -p ${DATA}/gitea/
sudo chmod 777 ${DATA}/gitea


init_db mysql7 3306 root ${PASSWORD:-} gitea
init_db mysql8 3306 root ${PASSWORD:-} gitea
