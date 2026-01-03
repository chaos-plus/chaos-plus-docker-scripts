
#!/bin/bash -e

################################################
## FRPC 
################################################

# 生成临时配置文件
# TEMP_CONF=$(mktemp)
# cat << EOF > ${TEMP_CONF}
# serverAddr = "${PORT_FRPS_URL:-127.0.0.1}"
# serverPort = ${PORT_FRPS_BIND:-7000}

# auth.token = "${HTPASSWD:-${PASSWORD:-pa44vv0rd}}"

# # [[proxies]]
# # name = "local-web"
# # type = "tcp"
# # localIP = "127.0.0.1"
# # localPort = 5173
# # remotePort = 7001

# EOF

# # 创建版本化 Docker config
# export FRPC_CONFIG=$(create_versioned_config "frpc-config" "${TEMP_CONF}" 3)
# rm -f ${TEMP_CONF}
