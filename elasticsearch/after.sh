#!/bin/bash -e


until sudo docker exec es curl -X GET "http://localhost:9200" --silent; do
  echo "⏳ Waiting for Elasticsearch to be ready..."
  sleep 2
done

echo "✅ Elasticsearch is ready!"

es_version=$(sudo docker exec -it es  env  | grep APP_VERSION | cut -d '=' -f 2)
es_version=$(echo "$es_version" | tr -d '\r\n')

echo "es_version: $es_version"
if sudo docker exec -it es bash -c "elasticsearch-plugin list | grep -q analysis-ik"; then
  echo "✅ analysis-ik 已安装。"
else
  echo "⏳ 正在安装 analysis-ik 插件..."
  sudo docker exec -it es bash -c "elasticsearch-plugin install --batch https://release.infinilabs.com/analysis-ik/stable/elasticsearch-analysis-ik-${es_version}.zip"
  sudo docker restart es
fi