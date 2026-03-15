#!/bin/bash

echo "========== Network Fix Script =========="

# 1. 自动检测真实网卡
iface=$(nmcli -t -f DEVICE,TYPE,STATE dev \
| awk -F: '$2=="ethernet" && $3=="connected"{print $1; exit}')

if [ -z "$iface" ]; then
    echo "❌ No active ethernet interface detected"
    exit 1
fi

echo "✔ Interface detected: $iface"

# 2. 获取 connection 名称
conn=$(nmcli -t -f NAME,DEVICE con show --active \
| awk -F: -v i="$iface" '$2==i{print $1; exit}')

if [ -z "$conn" ]; then
    echo "❌ No active NetworkManager connection found"
    exit 1
fi

echo "✔ Connection detected: $conn"

echo
echo "Applying DNS and disabling IPv6..."

# 3. 修改 DNS 和 IPv6
sudo nmcli connection modify "$conn" \
    ipv4.method auto \
    ipv4.dns "1.1.1.1 8.8.8.8" \
    ipv4.ignore-auto-dns yes \
    ipv6.method disabled

# 4. 重载配置
sudo nmcli connection reload

# 5. 重启网络连接
sudo nmcli connection down "$conn" >/dev/null 2>&1
sudo nmcli connection up "$conn"

echo
echo "========== RESULT =========="

echo
echo "Interface IPv4:"
ip -4 addr show "$iface"

echo
echo "DNS config:"
cat /etc/resolv.conf

echo
echo "NetworkManager DNS:"
nmcli dev show "$iface" | grep DNS

echo
echo "IPv6 status:"
ip -6 addr show "$iface"

echo
echo "✔ Network configuration completed"