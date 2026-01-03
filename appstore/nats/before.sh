#!/bin/bash -e


sudo mkdir -p ${DATA}/nats

sudo chmod -R 777 ${DATA}/nats

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 生成临时配置文件
echo "📝 生成配置文件..."
TEMP_CONF=$(mktemp)
cat > ${TEMP_CONF} << EOF
port: 4222
http: 8222

server_name: "nats-main"

jetstream {
  store_dir: /data/jetstream
}

authorization {
  user: "root"
  password: "${PASSWORD}"
}

# cluster {
#   name: "NATS"
#   listen: "0.0.0.0:6222"

#   routes = [
#     nats-route://root:${PASSWORD}@127.0.0.1:6222
#   ]

#   authorization {
#     user: "root"
#     password: "${PASSWORD}"
#   }
# }

EOF

# 创建版本化 Docker config
export NATS_CONFIG=$(create_versioned_config "nats-config" "${TEMP_CONF}" 3)
rm -f ${TEMP_CONF}
