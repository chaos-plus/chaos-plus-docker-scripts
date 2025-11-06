
#!/bin/bash -e

mkdir -p ${DATA}/gost
chmod -R 777 ${DATA}/gost

cd ${DATA}/gost

# 生成CA根证书（模拟Cloudflare企业级CA）
openssl req -x509 -newkey rsa:4096 -days 3650 -nodes \
  -keyout ca-key.pem \
  -out ca.pem \
  -subj "/C=US/ST=California/L=San Francisco/O=Cloudflare, Inc./OU=Cloudflare Security/CN=Cloudflare Enterprise CA" && \
# 生成服务端证书请求文件（绑定Cloudflare相关域名，可替换为实际使用的域名）
openssl req -newkey rsa:4096 -nodes \
  -keyout key.pem \
  -out cert.csr \
  -subj "/C=US/ST=California/L=San Francisco/O=Cloudflare, Inc./OU=Cloudflare Proxy/CN=proxy.cloudflare.com" && \
# 用CA根证书签署服务端证书（有效期10年）
openssl x509 -req -in cert.csr -days 3650 \
  -CA ca.pem -CAkey ca-key.pem -CAcreateserial \
  -out cert.pem && \
# 清理临时文件
rm -f cert.csr ca.srl ca-key.pem

ls -al
cd -