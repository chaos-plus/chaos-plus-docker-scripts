#!/bin/bash -e
set -u -o pipefail

########################
## DASHBOARD
##

# 获取外网 IP（若失败则给出提示）
IP_WAN=$(curl -s --max-time 5 4.ipw.cn || true)
if [ -z "${IP_WAN}" ]; then
    echo " WAN IP: (未知，外网 IP 获取失败)"
else
    echo " WAN IP: ${IP_WAN}"
fi

# 获取内网 IP（过滤本机回环和常见容器网段），仅展示第一条
if command -v ip &>/dev/null; then
    IP_LAN_LIST=$(ip -4 addr show | grep inet | awk '{print $2}' | grep -v '^127\.' | grep -v '0\.1/' | awk -F"/" '{print $1}' || true)
    IP_LAN=$(echo "${IP_LAN_LIST}" | head -n 1)
else
    IP_LAN=""
fi

if [ -z "${IP_LAN}" ]; then
    echo " LAN IP: (未知，未检测到有效内网 IP)"
else
    echo " LAN IP: ${IP_LAN}"
fi

echo ""
echo " 提示："
echo "   - 若部署在云服务器，请优先使用 WAN IP 访问应用入口"
echo "   - 若在内网环境，则可使用 LAN IP 进行访问调试"
echo ""
