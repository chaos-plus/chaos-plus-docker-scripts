#!/bin/bash -e

while [ ! -f "${DATA:-/opt/data}"/gitea/gitea/conf/app.ini ]; do
  echo "等待 ${DATA:-/opt/data}/gitea/gitea/conf/app.ini ..."
  sleep 1
done
sed -i 's/^DISABLE_REGISTRATION = false/DISABLE_REGISTRATION = true/' "${DATA:-/opt/data}"/gitea/gitea/conf/app.ini

