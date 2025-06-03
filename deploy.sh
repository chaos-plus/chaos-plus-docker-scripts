#!/bin/bash -e

set -e

WORK_SPACE=$(pwd)

function init() {
    ########################

    if command -v apt &>/dev/null; then
        apt install -y git wget curl vim fail2ban
    fi

    if command -v yum &>/dev/null; then
        yum install -y git wget curl vim fail2ban
    fi

    if [ ! -n "$(which ansible 2>/dev/null)" ]; then
        $PM install -y ansible
    fi

    if [ ! -n "$(which docker 2>/dev/null)" ]; then
        bash <(curl -sfL https://linuxmirrors.cn/docker.sh)
    fi

    if [ ! -n "$(which docker 2>/dev/null)" ]; then
        curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    fi

    if [ ! -n "$(which docker 2>/dev/null)" ]; then
        $PM install -y docker.io
    fi

    if [ ! -n "$(which docker 2>/dev/null)" ]; then
        $PM install -y docker-ce
    fi

    if ! command -v docker &>/dev/null; then
        echo "docker is not installed"
        exit 1
    fi


    if command -v docker-compose &>/dev/null; then
        if echo "$(docker-compose version --short 2>/dev/null)" | grep -q '^1\.'; then
            echo "docker-compose is v1.x, need upgrade"
            $PM uninstall -y docker-compose
        fi
    fi


    if ! command -v docker-compose &>/dev/null; then
        # 设置安装路径
        DEST=/usr/local/bin/docker-compose
        # 获取最新版本号（从 GitHub API）
        version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest \
            | grep '"tag_name":' | cut -d '"' -f 4)
        if [[ -z "$version" ]]; then
            echo "❌ 无法获取 docker-compose 最新版本号"
            exit 1
        fi
        echo "📦 正在下载 docker-compose $version ..."
        # 构建下载 URL
        url="https://github.com/docker/compose/releases/download/$version/docker-compose-$(uname -s)-$(uname -m)"
        # 下载并安装
        curl -L "$url" -o "$DEST"
        chmod +x "$DEST"
    fi

    if [ ! -n "$(which docker-compose 2>/dev/null)" ]; then
        $PM install -y docker-compose-plugin || true
        DOCKER_COMPOSE=$(find / -name docker-compose | grep "docker" 2>/dev/null)
        if [ -n "$DOCKER_COMPOSE" ]; then
            echo $DOCKER_COMPOSE
            sudo chmod 777 $DOCKER_COMPOSE
            \cp -rf $DOCKER_COMPOSE /usr/bin/docker-compose
        fi
    fi

    if ! command -v docker-compose &>/dev/null; then
        echo "docker-compose is not installed"
        exit 1
    fi

    ## 创建共享网络
    if [ -n "$(docker network list | grep ${NETWORK})" ]; then
        # NET EXISTS
        echo "docker network exists, skip"
    else
        # NET INIT
        echo "docker network lost, create"
        # docker network create --driver overlay --attachable cluster
        docker network create ${NETWORK}
    fi

    ########################
    sudo mkdir -p ${DATA}
}

function ui() {
    ########################
    echo "#################################################################################################################################"
    source ./ui.sh
    echo "#################################################################################################################################"
}

function compose() {
    if [ -z "$PULL" ]; then
        echo ""
    else
        local CMD_PULL="docker-compose pull"
        echo $CMD_PULL
        eval $CMD_PULL
    fi

    local CMD_UP="docker-compose -f $1 --compatibility up -d "
    echo "$(pwd) $CMD_UP"
    eval $CMD_UP
}

function deploy() {

    echo "deploy env ===> ${ENV}"
    echo "deploy domain ===> ${DOMAIN}"
    echo "deploy domains ===> ${DOMAINS[*]}"

    # 按顺序部署服务
    for serv in ${SERVICES[@]}; do #也可以写成for element in ${array[*]}
        cd $WORK_SPACE
        cd ${serv}
        echo ""
        echo "#####################################################################"
        echo "######################## service: ${serv} begin ########################"

        if [ ! -f '.noinit' ]; then
            init
        else
            echo "found .noinit file, skip init"
        fi
    
        # before
        [ -f "before.sh" ] && source before.sh $COMPOSE
        # before

        # compose.sh
        if [ -f "docker-compose-${ENV}.sh" ]; then
            source docker-compose-${ENV}.sh
        elif [ -f "docker-compose.sh" ]; then
            source docker-compose.sh
        else
            echo ""
        fi
        # compose.sh

        # compose.yml
        if [ -f "docker-compose-${ENV}.yml" ]; then
            compose docker-compose-${ENV}.yml
        elif [ -f "docker-compose.yml" ]; then
            compose docker-compose.yml
        else
            echo "missing docker-compose.yml"
        fi
        # compose.yml

        # after
        [ -f "after.sh" ] && source after.sh $COMPOSE
        # after

        cd $WORK_SPACE
        echo "######################## service: ${serv} end ########################"
        echo ""
        echo ""
    done

    cd $WORK_SPACE
    ui
}

function exec() {
    source ./env.sh
    source ./env.$1.sh
    export ENV=$1
    deploy
}

exec release
