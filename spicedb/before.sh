#!/bin/bash -e


docker exec -it mysql7 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS spicedb DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"


docker exec -it mysql8 mysql -uroot -p${PASSWORD} \
    -e "CREATE DATABASE IF NOT EXISTS spicedb DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"

export SPICEDB_VERSION=latest

docker run --rm -it --network ${NETWORK} authzed/spicedb:${SPICEDB_VERSION} \
datastore migrate head  \
--skip-release-check=true \
--log-level=debug \
--datastore-engine=mysql \
--datastore-conn-uri="root:${PASSWORD}@tcp(mysql8:3306)/spicedb?parseTime=true"
