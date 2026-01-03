
#!/bin/bash -e

################################################
## FRPS 
################################################
# 生成临时 TOML 配置文件
TEMP_CONF=$(mktemp)
cat << EOF > ${TEMP_CONF}
[common]
bind_port = ${PORT_FRPS_BIND:-7000}
allow_ports = "7000-7999"

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

# 创建版本化 Docker config
export FRPS_CONFIG=$(create_versioned_config "frps-config" "${TEMP_CONF}" 3)

# 删除临时文件
rm -f ${TEMP_CONF}
