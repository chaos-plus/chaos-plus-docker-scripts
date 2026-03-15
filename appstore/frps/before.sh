
#!/bin/bash -e

################################################
## FRPS 
################################################
# 生成临时 TOML 配置文件
mkdir -p ${DATA}/frps
cat << EOF > ${DATA}/frps/frps.toml
[common]
bind_port = ${PORT_FRPS_BIND:-7000}
allow_ports = "7000-65535"

dashboard_addr = "0.0.0.0"
dashboard_port = ${PORT_FRPS_UI:-7500}
dashboard_user = "admin"
dashboard_pwd = "${PASSWORD:-pa44vv0rd}"

token = "${HTPASSWORD:-${PASSWORD:-pa44vv0rd}}"

log_level = "debug"
log_max_days = 7
log_file = "/var/log/frps.log"
log_disable_color = false
detailed_errors_to_client = true

# 可选自定义 404 页面
# custom_404_page = "/path/to/404.html"
EOF

export FRPS_CONFIG_HASH=$(md5sum ${DATA}/frps/frps.toml | cut -d' ' -f1)