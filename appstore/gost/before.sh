
#!/bin/bash -e

mkdir -p ${DATA}/gost
chmod -R 777 ${DATA}/gost

GOST_CA_OUT="${DATA}/gost"


# 生成 CA 根证书
openssl req -x509 -newkey rsa:4096 -days 3650 -nodes \
  -keyout "${GOST_CA_OUT}/ca-key.pem" \
  -out "${GOST_CA_OUT}/ca.pem" \
  -subj "/C=US/ST=California/L=San Francisco/O=Cloudflare, Inc./OU=Cloudflare Security/CN=Cloudflare Enterprise CA"

# 生成服务端证书请求
openssl req -newkey rsa:4096 -nodes \
  -keyout "${GOST_CA_OUT}/key.pem" \
  -out "${GOST_CA_OUT}/cert.csr" \
  -subj "/C=US/ST=California/L=San Francisco/O=Cloudflare, Inc./OU=Cloudflare Proxy/CN=proxy.cloudflare.com"

# 用 CA 签署服务端证书
openssl x509 -req -in "${GOST_CA_OUT}/cert.csr" -days 3650 \
  -CA "${GOST_CA_OUT}/ca.pem" -CAkey "${GOST_CA_OUT}/ca-key.pem" -CAcreateserial \
  -out "${GOST_CA_OUT}/cert.pem"

# 清理临时文件
rm -f "${GOST_CA_OUT}/cert.csr" "${GOST_CA_OUT}/ca.srl"

ls -al "${GOST_CA_OUT}"