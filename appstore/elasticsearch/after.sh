#!/bin/bash -e

# 查找 elasticsearch 服务的实际容器名
get_container_name() {
    local service_name=$1
    docker ps -a --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

ES_CONTAINER=$(get_container_name "elasticsearch")

if [ -z "$ES_CONTAINER" ]; then
    echo "⚠️ elasticsearch 容器未找到，跳过健康检查"
    exit 0
fi

until sudo docker exec "$ES_CONTAINER" curl -X GET "http://localhost:9200" --silent; do
  echo "⏳ Waiting for Elasticsearch to be ready..."
  sleep 2
done

echo "✅ Elasticsearch is ready!"

es_version=$(sudo docker exec -it "$ES_CONTAINER"  env  | grep APP_VERSION | cut -d '=' -f 2)
es_version=$(echo "$es_version" | tr -d '\r\n')

echo "es_version: $es_version"
if sudo docker exec -it "$ES_CONTAINER" bash -c "elasticsearch-plugin list | grep -q analysis-ik"; then
  echo "✅ analysis-ik 已安装。"
else
  echo "⏳ 正在安装 analysis-ik 插件..."
  sudo docker exec -it "$ES_CONTAINER" bash -c "elasticsearch-plugin install --batch https://release.infinilabs.com/analysis-ik/stable/elasticsearch-analysis-ik-${es_version}.zip"
  sudo docker restart "$ES_CONTAINER"
fi