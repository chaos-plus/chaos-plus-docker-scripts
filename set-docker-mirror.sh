#!/bin/bash -e
set -u -o pipefail

echo "=========================================="
echo "  配置 Docker 镜像加速与系统参数"
echo "=========================================="
echo ""

echo " 准备 /etc/docker 目录..."
sudo mkdir -p /etc/docker

# 若已存在 daemon.json，则先做备份
if [ -f /etc/docker/daemon.json ]; then
    backup="/etc/docker/daemon.json.bak-$(date +%Y%m%d%H%M%S)"
    echo " 检测到已有 /etc/docker/daemon.json，备份到: ${backup}"
    sudo cp /etc/docker/daemon.json "${backup}"
fi

echo " 写入 /etc/docker/daemon.json ..."
sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
    "registry-mirrors": [
        "https://docker.1ms.run",
        "https://docker.xuanyuan.me",
        "https://docker.m.daocloud.io",
        "https://mirror.ccs.tencentyun.com"
    ],
    "insecure-registries": [
      "sealos.hub:5000"
    ],
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

echo " 当前 Docker 配置:"
sudo cat /etc/docker/daemon.json

echo ""
echo " 配置 Docker systemd 句柄数限制 ..."
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo chmod 755 /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/limit-nofile.conf >/dev/null <<EOF
[Service]
LimitNOFILE=1048576
EOF

echo ""
echo " 重新加载并重启 Docker 服务 ..."
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl restart docker
echo " Docker 服务已重启"
