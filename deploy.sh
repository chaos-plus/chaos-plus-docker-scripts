#!/bin/bash -e

set -e
set -o pipefail

WORK_SPACE=$(pwd)


pm_install_one() {
    local package_name="$1"
    # 判断系统并选择合适的包管理器
    if command -v apt &>/dev/null; then
        # 使用 apt
        if apt search "$package_name" | grep -q "$package_name"; then
            echo "Installing $package_name using apt."
            sudo apt install -y "$package_name"
            return
        else
            echo "Package '$package_name' not found in apt repository."
        fi
    fi

    if command -v apt-get &>/dev/null; then
        # 使用 apt-get
        if apt-cache search "$package_name" | grep -q "$package_name"; then
            echo "Installing $package_name using apt-get."
            sudo apt-get install -y "$package_name"
            return
        else
            echo "Package '$package_name' not found in apt-get repository."
        fi
    fi

    if command -v yum &>/dev/null; then
        # 使用 yum
        if yum list available "$package_name" &>/dev/null; then
            echo "Installing $package_name using yum."
            sudo yum install -y "$package_name"
            return
        else
            echo "Package '$package_name' not found in yum repository."
        fi
    fi

    if command -v pacman &>/dev/null; then
        # 使用 pacman
        if pacman -Q "$package_name" &>/dev/null; then
            echo "✅ Package '$package_name' is already installed."
            return
        else
            echo "📦 Installing '$package_name' using pacman..."
            if sudo pacman -S --noconfirm "$package_name"; then
                echo "✅ Installed '$package_name' successfully."
                return
            else
                echo "❌ Failed to install '$package_name'. Maybe it doesn't exist in repositories?"
            fi
        fi
    fi

    if command -v dnf &>/dev/null; then
        # 使用 dnf
        if dnf list available "$package_name" &>/dev/null; then
            echo "Installing $package_name using dnf."
            sudo dnf install -y "$package_name"
            return
        else
            echo "Package '$package_name' not found in dnf repository."
        fi
    fi

    if command -v snap &>/dev/null; then
        # 使用 snap
        if snap info "$package_name" &>/dev/null; then
            echo "Installing $package_name using snap."
            sudo snap install "$package_name"
            return
        else
            echo "Package '$package_name' not found in snap repository."
        fi
    fi

    if command -v yay &>/dev/null; then
        # 使用 yay
        if yay -Ss "$package_name" | grep -q "$package_name"; then
            echo "Installing $package_name using yay."
            yay -S --noconfirm "$package_name"
            return
        else
            echo "Package '$package_name' not found in yay repository."
        fi
    fi

    if command -v zypper &>/dev/null; then
        # 使用 zypper
        if zypper search "$package_name" &>/dev/null; then
            echo "Installing $package_name using zypper."
            sudo zypper install -y "$package_name"
            return
        else
            echo "Package '$package_name' not found in zypper repository."
        fi
    fi

    if command -v brew &>/dev/null; then
        # 使用 brew
        if brew search "$package_name" &>/dev/null; then
            echo "Installing $package_name using brew."
            brew install "$package_name"
            return
        else
            echo "Package '$package_name' not found in brew repository."
        fi
    fi

    if command -v flatpak &>/dev/null; then
        # 使用 flatpak
        if flatpak search "$package_name" &>/dev/null; then
            echo "Installing $package_name using flatpak."
            sudo flatpak install -y "$package_name"
            return
        else
            echo "Package '$package_name' not found in flatpak repository."
        fi
    fi

    if command -v port &>/dev/null; then
        # 使用 port
        if port search "$package_name" &>/dev/null; then
            echo "Installing $package_name using port."
            sudo port install "$package_name"
            return
        else
            echo "Package '$package_name' not found in port repository."
        fi
    fi

    if command -v conda &>/dev/null; then
        # 使用 conda
        if conda search "$package_name" &>/dev/null; then
            echo "Installing $package_name using conda."
            conda install -y "$package_name"
            return
        else
            echo "Package '$package_name' not found in conda repository."
        fi
    fi

    if command -v nix &>/dev/null; then
        # 使用 nix
        if nix search "$package_name" &>/dev/null; then
            echo "Installing $package_name using nix."
            nix-env -i "$package_name"
            return
        else
            echo "Package '$package_name' not found in nix repository."
        fi
    fi

    echo "Package manager not supported on this system."
}

pm_uninstall_one() {
    local package_name="$1"

    # 判断系统并选择合适的包管理器进行卸载
    if command -v apt &>/dev/null; then
        # 使用 apt
        if dpkg-query -l "$package_name" &>/dev/null; then
            echo "Uninstalling $package_name using apt."
            sudo apt remove -y "$package_name"
            sudo apt autoremove -y
            return
        else
            echo "Package '$package_name' not found in apt repository."
        fi
    fi

    if command -v apt-get &>/dev/null; then
        # 使用 apt-get
        if dpkg-query -l "$package_name" &>/dev/null; then
            echo "Uninstalling $package_name using apt-get."
            sudo apt-get remove -y "$package_name"
            sudo apt-get autoremove -y
            return
        else
            echo "Package '$package_name' not found in apt-get repository."
        fi
    fi

    if command -v yum &>/dev/null; then
        # 使用 yum
        if yum list installed "$package_name" &>/dev/null; then
            echo "Uninstalling $package_name using yum."
            sudo yum remove -y "$package_name"
            sudo yum autoremove -y
            return
        else
            echo "Package '$package_name' not found in yum repository."
        fi
    fi

    if command -v pacman &>/dev/null; then
        # 使用 pacman
        if pacman -Qs "$package_name" | grep -q "$package_name"; then
            echo "Uninstalling $package_name using pacman."
            sudo pacman -R --noconfirm "$package_name"
            sudo pacman -R $(pacman -Qdtq)
            return
        else
            echo "Package '$package_name' not found in pacman repository."
        fi
    fi

    if command -v dnf &>/dev/null; then
        # 使用 dnf
        if dnf list installed "$package_name" &>/dev/null; then
            echo "Uninstalling $package_name using dnf."
            sudo dnf remove -y "$package_name"
            sudo dnf autoremove -y
            return
        else
            echo "Package '$package_name' not found in dnf repository."
        fi
    fi

    if command -v snap &>/dev/null; then
        # 使用 snap
        if snap list "$package_name" &>/dev/null; then
            echo "Uninstalling $package_name using snap."
            sudo snap remove "$package_name" --purge
            return
        else
            echo "Package '$package_name' not found in snap repository."
        fi
    fi

    if command -v yay &>/dev/null; then
        # 使用 yay
        if yay -Qs "$package_name" | grep -q "$package_name"; then
            echo "Uninstalling $package_name using yay."
            yay -R --noconfirm "$package_name"
            yay -R $(yay -Qdtq)
            return
        else
            echo "Package '$package_name' not found in yay repository."
        fi
    fi

    if command -v zypper &>/dev/null; then
        # 使用 zypper
        if zypper search --installed-only "$package_name" &>/dev/null; then
            echo "Uninstalling $package_name using zypper."
            sudo zypper remove -y "$package_name"
            sudo zypper autoremove -y
            return
        else
            echo "Package '$package_name' not found in zypper repository."
        fi
    fi

    if command -v brew &>/dev/null; then
        # 使用 brew
        if brew list "$package_name" &>/dev/null; then
            echo "Uninstalling $package_name using brew."
            brew uninstall "$package_name"
            brew cleanup --prune=all
            return
        else
            echo "Package '$package_name' not found in brew repository."
        fi
    fi

    if command -v flatpak &>/dev/null; then
        # 使用 flatpak
        if flatpak list | grep -q "$package_name"; then
            echo "Uninstalling $package_name using flatpak."
            sudo flatpak uninstall -y "$package_name"
            return
        else
            echo "Package '$package_name' not found in flatpak repository."
        fi
    fi

    if command -v port &>/dev/null; then
        # 使用 port
        if port installed | grep -q "$package_name"; then
            echo "Uninstalling $package_name using port."
            sudo port uninstall "$package_name"
            sudo port autoremove -y
            return
        else
            echo "Package '$package_name' not found in port repository."
        fi
    fi

    if command -v conda &>/dev/null; then
        # 使用 conda
        if conda list | grep -q "$package_name"; then
            echo "Uninstalling $package_name using conda."
            conda remove -y "$package_name"
            conda clean -y
            return
        else
            echo "Package '$package_name' not found in conda repository."
        fi
    fi

    if command -v nix &>/dev/null; then
        # 使用 nix
        if nix-env -q | grep -q "$package_name"; then
            echo "Uninstalling $package_name using nix."
            nix-env -e "$package_name"
            nix-env --delete-generations old
            return
        else
            echo "Package '$package_name' not found in nix repository."
        fi
    fi

    echo "Package manager not supported on this system."
}

pm_install() {
    for package_name in "$@"; do
        pm_install_one "$package_name"
    done
}

pm_uninstall() {
    for package_name in "$@"; do
        pm_uninstall_one "$package_name"
    done
    hash -r
}


function init() {
    ########################

    echo "📦 安装基础依赖: git wget curl vim fail2ban ansible"

    pm_install git wget curl vim fail2ban ansible

    echo "🐳 检查 Docker 安装..."
    if ! command -v docker &>/dev/null; then
        # 优先使用国内镜像脚本安装 Docker
        sudo curl -fsSL https://linuxmirrors.cn/docker.sh | bash || echo "⚠️ linuxmirrors.cn 安装脚本执行失败，继续尝试其他方式"
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
        echo "docker is not installed"
        exit 1
    fi


    echo "🧩 检查 docker-compose 安装..."
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
            echo $DOCKER_COMPOSE
            sudo chmod 755 $DOCKER_COMPOSE
            sudo \cp -rf $DOCKER_COMPOSE /usr/bin/docker-compose
        fi
    fi

    if ! command -v docker-compose &>/dev/null; then
        echo "docker-compose is not installed"
        exit 1
    fi

    # ( ( ( (sudo usermod -aG docker $USER) ) ) )
    # ( ( ( (newgrp docker) ) ) )

    sudo docker version
    sudo docker info
    sudo docker ps -a

    if [ "${MODE}" = "stack" ]; then
        local swarm_state
        swarm_state=$(sudo docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || true)
        if [[ "${swarm_state}" != "active" && "${swarm_state}" != "locked" ]]; then
            echo "⚠️ Stack 模式需要 Docker Swarm，请先执行 'sudo docker swarm init'"
            exit 1
        fi
    fi

    ## 创建共享网络
    echo "🌐 检查 Docker 网络: ${NETWORK}"
    if sudo docker network inspect "${NETWORK}" >/dev/null 2>&1; then
        # NET EXISTS
        echo "✅ docker 网络已存在，跳过创建"
    else
        # NET INIT
        echo "🚧 docker 网络不存在，正在创建: ${NETWORK}"
        local network_driver="bridge"
        local network_cmd=(sudo docker network create)
        if [ "${MODE}" = "stack" ]; then
            network_driver="overlay"
            network_cmd+=(--driver "${network_driver}" --attachable)
        else
            network_cmd+=(--driver "${network_driver}")
        fi
        network_cmd+=("${NETWORK}")
        "${network_cmd[@]}"
    fi

    ########################
    echo "📁 准备数据目录: ${DATA}"
    sudo mkdir -p "${DATA}"
}

function ui() {
    ########################
    echo "#################################################################################################################################"
    source ./ui.sh
    echo "#################################################################################################################################"
}

function compose() {
    local COMPOSE_FILE="$1"
    local SERVICE_NAME="${2:-$(basename "$(pwd)")}"
    local mode="${MODE:-compose}"

    if [ "${mode}" = "stack" ]; then
        if [ -n "${PULL:-}" ]; then
            echo "⚠️ stack 模式暂不支持 pull-only，跳过 ${SERVICE_NAME}"
            return 0
        fi

        local stack="${STACK_NAME:-${SERVICE_NAME}}"
        local CMD_STACK="sudo -E docker stack deploy --with-registry-auth -c ${COMPOSE_FILE} ${stack}"
        echo "$(pwd) ${CMD_STACK}"
        eval "${CMD_STACK}"
        return 0
    fi

    # 如果启用 PULL 模式，则仅拉取镜像，不执行 up
    if [ -n "${PULL:-}" ]; then
        local CMD_PULL="sudo -E docker-compose -f ${COMPOSE_FILE} --compatibility pull"
        echo "$(pwd) ${CMD_PULL}"
        eval "${CMD_PULL}"
        return 0
    fi

    local CMD_UP="sudo -E docker-compose -f ${COMPOSE_FILE} --compatibility up -d"
    echo "$(pwd) ${CMD_UP}"
    eval "${CMD_UP}"
}

function deploy() {

    
    echo "🌎 部署环境: ${ENV}"
    echo "🚀 部署模式: ${MODE}"
    echo "🌐 主域名: ${DOMAIN}"
    if declare -p DOMAINS >/dev/null 2>&1; then
        echo "🌐 其他域名: ${DOMAINS[*]}"
    else
        echo "🌐 其他域名: (未配置)"
    fi
    echo ""

    if [ -z "${SERVICES:-}" ]; then
        SERVICES=("${@:1}" )
    fi

    if [ -z "${SERVICES:-}" ]; then
        SERVICES=( $(find . -maxdepth 1 -type d -not -name '.*' -printf '%f\n') )
        echo "services is empty, please input services: ${SERVICES[*]}"
        exit 1
    fi

    echo "📋 将要部署的服务列表: ${SERVICES[*]}"

    init

    # 按顺序部署服务
    for serv in "${SERVICES[@]}"; do #也可以写成for element in ${array[*]}
        cd "$WORK_SPACE"

        if [ ! -d "${serv}" ]; then
            echo "service ${serv} not found"
            continue
        fi

        if [[ "$serv" == "."* || "$serv" == "-"* ]]; then
            echo "service ${serv} ignored"
            continue
        fi



        cd "${serv}"
        echo ""
        echo "#####################################################################"
        echo "######################## service: ${serv} begin ########################"

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
            compose docker-compose-${ENV}.yml "${serv}"
        elif [ -f "docker-compose.yml" ]; then
            compose docker-compose.yml "${serv}"
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

    cd "$WORK_SPACE"
    ui
}


if [ -z "${ENV:-}" ]; then
    ENV=release
fi
if [ -f "./env.sh" ]; then
    source ./env.sh
fi

if [ ! -f "./env.${ENV}.sh" ]; then
    \cp ./env.example.sh ./env.${ENV}.sh
    echo " 已生成环境配置文件: env.${ENV}.sh，请按需修改后重新执行。"
    vim ./env.${ENV}.sh
fi

if [ -f "./env.${ENV}.sh" ]; then
    echo " 载入环境配置: env.${ENV}.sh"
    source ./env.${ENV}.sh
fi

if [ -z "${MODE:-}" ]; then
    MODE=compose
fi

echo " 开始执行部署流程..."

# 支持 ./deploy.sh pull [service1 service2 ...] 模式：仅拉取镜像，不启动容器
if [ "${1:-}" = "pull" ]; then
    export PULL=1
    shift
fi

deploy "$@"
