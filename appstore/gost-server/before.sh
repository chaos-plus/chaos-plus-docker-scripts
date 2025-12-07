
#!/bin/bash -e

mkdir -p ${DATA}/gost
chmod -R 777 ${DATA}/gost

export GOST_TOKEN=${GOST_TOKEN:-${PASSWORD}}

GOST_CA_OUT="${DATA}/gost"

# 生成 CA 根证书
# 如果证书和私钥都已存在，则跳过生成
if [ -f "${GOST_CA_OUT}/ca.pem" ] && [ -f "${GOST_CA_OUT}/ca-key.pem" ] \
   && [ -f "${GOST_CA_OUT}/cert.pem" ] && [ -f "${GOST_CA_OUT}/key.pem" ]; then
  echo "证书已存在，跳过生成"
else
  # 生成 CA 根证书（仅当不存在时）
  if [ ! -f "${GOST_CA_OUT}/ca.pem" ] || [ ! -f "${GOST_CA_OUT}/ca-key.pem" ]; then
    openssl req -x509 -newkey rsa:4096 -days 3650 -nodes \
      -keyout "${GOST_CA_OUT}/ca-key.pem" \
      -out "${GOST_CA_OUT}/ca.pem" \
      -subj "/C=US/ST=California/L=San Francisco/O=Cloudflare, Inc./OU=Cloudflare Security/CN=Cloudflare Enterprise CA"
  fi

  # 生成服务端证书私钥和 CSR（私钥不存在时才生成；CSR 始终为临时文件）
  if [ -f "${GOST_CA_OUT}/key.pem" ]; then
    # 已有私钥则复用，仅生成新的 CSR
    openssl req -new -key "${GOST_CA_OUT}/key.pem" \
      -out "${GOST_CA_OUT}/cert.csr" \
      -subj "/C=US/ST=California/L=San Francisco/O=Cloudflare, Inc./OU=Cloudflare Proxy/CN=proxy.cloudflare.com"
  else
    # 无私钥则创建新的
    openssl req -newkey rsa:4096 -nodes \
      -keyout "${GOST_CA_OUT}/key.pem" \
      -out "${GOST_CA_OUT}/cert.csr" \
      -subj "/C=US/ST=California/L=San Francisco/O=Cloudflare, Inc./OU=Cloudflare Proxy/CN=proxy.cloudflare.com"
  fi

  # 如果服务端证书不存在，则用 CA 签发
  if [ ! -f "${GOST_CA_OUT}/cert.pem" ]; then
    openssl x509 -req -in "${GOST_CA_OUT}/cert.csr" -days 3650 \
      -CA "${GOST_CA_OUT}/ca.pem" -CAkey "${GOST_CA_OUT}/ca-key.pem" -CAcreateserial \
      -out "${GOST_CA_OUT}/cert.pem"
  fi

  # 清理临时文件
  rm -f "${GOST_CA_OUT}/cert.csr" "${GOST_CA_OUT}/ca.srl"
fi

ls -al "${GOST_CA_OUT}"