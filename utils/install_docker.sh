#!/bin/bash -e

INFO "🐳 检查 Docker 安装..."
if ! command -v docker &>/dev/null; then
    # 优先使用国内镜像脚本安装 Docker
    sudo curl -fsSL https://linuxmirrors.cn/docker.sh | bash || WARN "linuxmirrors.cn 安装脚本执行失败，继续尝试其他方式"
fi

if ! command -v docker &>/dev/null; then
    if [ -n "$HAS_GOOGLE" ]; then
        sudo curl -fsSL https://get.docker.com | bash -s docker
    else
        sudo curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    fi
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
