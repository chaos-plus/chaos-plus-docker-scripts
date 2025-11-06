#!/bin/bash -e

sudo mkdir -p /etc/docker
sudo chmod 777 -R /etc/docker
sudo cat > /etc/docker/daemon.json <<EOF
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
sudo cat /etc/docker/daemon.json
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo chmod 777 /etc/systemd/system/docker.service.d
sudo cat > /etc/systemd/system/docker.service.d/limit-nofile.conf <<EOF
[Service]
LimitNOFILE=1048576
EOF

sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl restart docker
