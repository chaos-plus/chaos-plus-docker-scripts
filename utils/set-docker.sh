#!/bin/bash -e

source "$(dirname "$0")/function.sh"

BLUE "=========================================="
GREEN "  配置 Docker daemon.json"
BLUE "=========================================="
echo ""
 
INFO "准备 /etc/docker 目录..."
sudo mkdir -p /etc/docker

# 若已存在 daemon.json，则先做备份
if [ -f /etc/docker/daemon.json ]; then
    backup="/etc/docker/daemon.json.bak-$(date +%Y%m%d%H%M%S)"
    NOTE "检测到已有 /etc/docker/daemon.json，备份到: ${backup}"
    sudo cp /etc/docker/daemon.json "${backup}"
fi

INFO "写入 /etc/docker/daemon.json ..."
sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
    "max-concurrent-downloads": 20,
    "log-driver": "json-file",
    "log-level": "warn",
    "log-opts": {"max-size": "1024m", "max-file": "3"},
    "exec-opts": ["native.cgroupdriver=systemd"],
    "storage-driver": "overlay2",
    "default-shm-size": "128M",
    "live-restore": true,
    "userland-proxy": false,
    "iptables": true,
    "ipv6": false,
    "experimental": false,
    "metrics-addr": "127.0.0.1:9323"
}
EOF

sudo chmod 644 /etc/docker/daemon.json
sudo chmod 755 /etc/docker

INFO "当前 Docker 配置:"
sudo cat /etc/docker/daemon.json

echo ""
INFO "配置 Docker systemd 句柄数限制 ..."
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo chmod 755 /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/limit-nofile.conf >/dev/null <<EOF
[Service]
LimitNOFILE=1048576
EOF

echo ""
INFO "重新加载并重启 Docker 服务 ..."
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl restart docker
SUCCESS "Docker 服务已重启"
