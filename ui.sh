#!/bin/bash -e

########################
## DASHBOARD

IP_WAN=$(curl -s 4.ipw.cn)
echo "WAN IP: $IP_WAN"

IP_LAN=$(ip addr | grep inet | grep -v inet6 | awk '{print $2}' | grep -v 127.0.0.1 | grep -v '172.*.*.*' | awk -F"/" '{print $1}')

echo "LAN IP: $IP_LAN"

IP=$IP_WAN

echo "------"

if [ -n "$(docker ps | grep ghproxy)" ]; then
    echo -e "GH PROXY ->* \e[4;34m http://$IP:${PROXY_GH} \e[0m"
fi

if [ -n "$(docker ps | grep crproxy)" ]; then
    echo -e "CR PROXY ->* \e[4;34m http://$IP:${PROXY_CR} \e[0m"
fi

echo ""
echo ""

##
