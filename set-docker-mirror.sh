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
    "max-concurrent-downloads": 20,
    "log-driver": "json-file",
    "log-level": "warn",
    "log-opts": {"max-size":"100m", "max-file":"1"},
    "exec-opts": ["native.cgroupdriver=systemd"],
    "storage-driver": "overlay2",
    "insecure-registries": [
      "sealos.hub:5000"
    ],
    "data-root": "/var/lib/docker"
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