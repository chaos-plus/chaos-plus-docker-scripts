#!/bin/bash -e


export XXLJOB_TOKEN=${XXLJOB_TOKEN:-${PASSWORD:-}}


sudo mkdir -p ${DATA}/xxljob

sudo wget ${GHPROXY:-}https://raw.githubusercontent.com/xuxueli/xxl-job/refs/heads/master/doc/db/tables_xxl_job.sql -O ${DATA}/xxljob/tables_xxl_job.sql

sudo sed -i -E '/^CREATE TABLE[^;]*$/I{/IF NOT EXISTS/I!s/CREATE TABLE/CREATE TABLE IF NOT EXISTS/}' ${DATA}/xxljob/tables_xxl_job.sql
sudo sed -i -E 's/^INSERT[[:space:]]+INTO/INSERT IGNORE INTO/I' ${DATA}/xxljob/tables_xxl_job.sql


init_db mysql8 root ${PASSWORD:-} xxl_job

init_sql mysql8 root ${PASSWORD:-} xxl_job ${DATA}/xxljob/tables_xxl_job.sql