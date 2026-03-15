
#!/bin/bash -e

################################################
## FRPC 
################################################

# 生成临时配置文件
mkdir -p ${DATA}/frpc
cat << EOF > ${DATA}/frpc/frpc.toml
serverAddr = "${PORT_FRPS_URL:-127.0.0.1}"
serverPort = ${PORT_FRPS_BIND:-7000}

auth.token = "${HTPASSWD:-${PASSWORD:-pa44vv0rd}}"

# [[proxies]]
# name = "local-web"
# type = "tcp"
# localIP = "127.0.0.1"
# localPort = 5173
# remotePort = 7001

EOF

export FRPC_CONFIG_HASH=$(md5sum ${DATA}/frpc/frpc.toml | cut -d' ' -f1)