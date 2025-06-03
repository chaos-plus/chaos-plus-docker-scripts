#!/bin/bash -e

################################################
## Traefik
################################################
if [ -d "${DATA}/traefik" ]; then
    echo "traefik data exists, skip"
else
    echo "traefik data lost, create"
fi

################################################

# FRPS ################################################

mkdir -p ${DATA}/frps
cat <<EOF >${DATA}/frps/frps.toml
bindPort = 7000
tcpmuxHTTPConnectPort = 8000
vhostHTTPPort = 8080
webServer.addr = "0.0.0.0"
webServer.port = 7500
webServer.user = "admin"
webServer.password = "pa44vv0rd"
auth.token = "${HTPASSWORD}"
log.level = "debug"
log.maxDays = 7
log.disablePrintColor = false
detailedErrorsToClient = true
# 用于 HTTP 请求的自定义 404 页面
# custom404Page = "/path/to/404.html"
EOF

# FRPS ################################################
