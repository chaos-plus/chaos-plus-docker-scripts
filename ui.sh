#!/bin/bash -e

########################
## DASHBOARD

IP_WAN=$(curl -s 4.ipw.cn)
echo "WAN IP: $IP_WAN"

IP_LAN=$(ip addr | grep inet | grep -v inet6 | awk '{print $2}' | grep -v 127.0.0.1 | grep -v '172.*.*.*' | awk -F"/" '{print $1}')

echo "LAN IP: $IP_LAN"

##
