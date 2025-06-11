#!/bin/bash -e

get_github_release_version() {
    local repo=$1
    if [[ $repo =~ releases/latest ]]; then
        local url="https://api.github.com/repos/$repo"
    else
        local url="https://api.github.com/repos/$repo/releases/latest"
    fi
    echo $(curl -sfL $url | grep -oE '"tag_name": "[^"]+"' | head -n1 | cut -d'"' -f4)
}

export HOSTNAME=$(hostname)

if [ -f "/usr/bin/apt" ]; then
    export PM=/usr/bin/apt
fi
if [ -f "/usr/bin/yum" ]; then
    export PM=/usr/bin/yum
fi

export NETWORK=traefik

export SERV_NAME=cloud

export TEMP=/opt/tmp
export DATA=/opt/data

mkdir -p ${TEMP}
mkdir -p ${DATA}

export RES_LIMIT_MEM="512M"
export RES_RESER_MEM="512M"

export PORT_PROXY=80
export PORT_PROXY_SSL=443
export PORT_PROXY_DASHBOARD=8081

export PORT_FRPS_BIND=7777

export PORT_HIDDIFY=8080
export PORT_HIDDIFY_SSL=8443

export PORT_PROXY_GH=9511
export PORT_PROXY_CR=9522
export PROXY_CR_VERSION=$(get_github_release_version "DaoCloud/crproxy")
