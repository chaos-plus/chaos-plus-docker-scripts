
#!/bin/bash -e


if [ -z "${DOMAIN:-}" ]; then
    echo "DOMAIN is empty"
    exit 1
fi


################################################
## Traefik
################################################
if [ -d "${DATA}/traefik" ]; then
    echo "traefik data exists, skip"
else
    echo "traefik data lost, create"
fi


sudo mkdir -p ${DATA}/traefik/config/
sudo mkdir -p ${DATA}/traefik/data/
sudo mkdir -p ${DATA}/traefik/log/


SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 生成临时配置文件
TEMP_CONF=$(mktemp)
cp ${SRC_DIR}/traefik.tls.toml ${TEMP_CONF}

# 替换域名
sed -i "s/MY_DOMAIN.key/${DOMAIN}.key/g" ${TEMP_CONF}

if [ -d "${DATA}/acme/${DOMAIN}_ecc" ]; then
    sed -i "s/MY_DOMAIN/${DOMAIN}_ecc/g" ${TEMP_CONF}
else
    sed -i "s/MY_DOMAIN/${DOMAIN}/g" ${TEMP_CONF}
fi

# 创建版本化 Docker config
export TRAEFIK_TLS_CONFIG=$(create_versioned_config "traefik-tls-config" "${TEMP_CONF}" 3)
rm -f ${TEMP_CONF}

sudo chmod -R 777 ${DATA}/traefik

################################################
