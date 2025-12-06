#!/bin/bash -e

INFO "🐳 检查 Docker 安装..."
if ! command -v docker &>/dev/null; then
    # 优先使用国内镜像脚本安装 Docker
    sudo curl -fsSL https://linuxmirrors.cn/docker.sh | bash || WARN "linuxmirrors.cn 安装脚本执行失败，继续尝试其他方式"
fi

if ! command -v docker &>/dev/null; then
    sudo curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
fi

if ! command -v docker &>/dev/null; then
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm docker || true
    fi
fi

if ! command -v docker &>/dev/null; then
    ERROR "docker is not installed"
    exit 1
fi


INFO "🧩 检查 docker-compose 安装..."
if ! command -v docker-compose &>/dev/null; then
    # 设置安装路径
    DEST=/usr/local/bin/docker-compose
    # 获取最新版本号（从 GitHub API）
    version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest \
        | grep '"tag_name":' | cut -d '"' -f 4)
    if [[ -z "$version" ]]; then
        ERROR "无法获取 docker-compose 最新版本号"
        exit 1
    fi
    INFO "📦 正在下载 docker-compose $version ..."
    # 构建下载 URL
    url="https://github.com/docker/compose/releases/download/$version/docker-compose-$(uname -s)-$(uname -m)"
    # 下载并安装
    sudo curl -L "$url" -o "$DEST"
    sudo chmod +x "$DEST"
fi

if [ ! -n "$(which docker-compose 2>/dev/null)" ]; then
    if command -v apt &>/dev/null; then
        sudo apt install -y docker-compose-plugin || true
    fi
    if command -v yum &>/dev/null; then
        sudo yum install -y docker-compose-plugin || true
    fi
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm docker-compose || true
    fi

    DOCKER_COMPOSE=$(find / -name docker-compose | grep "docker" 2>/dev/null)
    if [ -n "$DOCKER_COMPOSE" ]; then
        INFO "$DOCKER_COMPOSE"
        sudo chmod 755 $DOCKER_COMPOSE
        sudo \cp -rf $DOCKER_COMPOSE /usr/bin/docker-compose
    fi
fi

if ! command -v docker-compose &>/dev/null; then
    ERROR "docker-compose is not installed"
    exit 1
fi

# ( ( ( (sudo usermod -aG docker $USER) ) ) )
# ( ( ( (newgrp docker) ) ) )

sudo docker version
sudo docker info
sudo docker ps -a


## 创建共享网络
INFO "🌐 检查 Docker 网络: ${NETWORK:-bridge}"
export NETWORK=${NETWORK:-bridge}
export MODE=${MODE:-compose}
if sudo docker network inspect "${NETWORK}" >/dev/null 2>&1; then
    # NET EXISTS - 检查 scope 是否匹配
    current_scope=$(sudo docker network inspect "${NETWORK}" --format '{{.Scope}}' 2>/dev/null || echo "")
    
    if [ "${MODE:-compose}" = "stack" ] && [ "${current_scope}" = "local" ]; then
        WARN "网络 ${NETWORK} scope 为 local，stack 模式需要 swarm scope"
        INFO "🔄 正在删除并重建网络..."
        sudo docker network rm "${NETWORK}" || true
        sudo docker network create --driver overlay --attachable "${NETWORK}"
        SUCCESS "网络已重建为 overlay (swarm scope)"
    elif [ "${MODE:-compose}" = "compose" ] && [ "${current_scope}" = "swarm" ]; then
        INFO "网络 ${NETWORK} scope 为 swarm，compose 模式仍可使用"
    else
        SUCCESS "docker 网络已存在，scope: ${current_scope}"
    fi
else
    # NET INIT
    INFO "🚧 docker 网络不存在，正在创建: ${NETWORK}"
    network_driver="bridge"
    network_cmd=(sudo docker network create)
    if [ "${MODE:-compose}" = "stack" ]; then
        network_driver="overlay"
        network_cmd+=(--driver "${network_driver}" --attachable)
    else
        network_cmd+=(--driver "${network_driver}")
    fi
    network_cmd+=("${NETWORK}")
    "${network_cmd[@]}"
fi