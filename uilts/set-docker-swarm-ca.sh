#!/bin/bash -e

source "$(dirname "$0")/function.sh"

swarm_state=$(sudo docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || true)
if [[ "${swarm_state}" != "active" && "${swarm_state}" != "locked" ]]; then
    WARN "Stack 模式需要 Docker Swarm，请先执行 'sudo docker swarm init'"
    exit 1
fi

docker swarm update --cert-expiry 867240h0m0s
docker swarm ca --rotate | openssl x509 -text -noout
docker swarm ca --rotate

docker system info | grep Duration