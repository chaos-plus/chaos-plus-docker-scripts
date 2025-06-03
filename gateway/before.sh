
#!/bin/bash -e


################################################
## Traefik
################################################
if [ -d "${DATA}/traefik" ]; then
    echo "traefik data exists, skip"
else
    echo "traefik data lost, create"
fi


mkdir -p ${DATA}/traefik/config/

export TRAEFIX_CONF=${DATA}/traefik/config/
cp -rf ./traefik*.*ml ${TRAEFIX_CONF}

sudo sed -i "s/MY_DOMAIN.key/${DOMAIN}.key/g" `grep MY_DOMAIN -rl ${TRAEFIX_CONF}`

if [ -d "${DATA}/acme/${DOMAIN}_ecc" ]; then
    sudo sed -i "s/MY_DOMAIN/${DOMAIN}_ecc/g" `grep MY_DOMAIN -rl ${TRAEFIX_CONF}`
else
    sudo sed -i "s/MY_DOMAIN/${DOMAIN}/g" `grep MY_DOMAIN -rl ${TRAEFIX_CONF}`
fi

################################################


# FRPS ################################################

mkdir -p ${DATA}/frps
cat << EOF > ${DATA}/frps/frps.toml
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