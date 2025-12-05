#!/bin/bash -e


export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;36m'
export BBLUE='\033[0;34m'
export PLAIN='\033[0m'
export RESET="\033[0m"

export NOTE="[${BLUE}NOTE${RESET}]"
export INFO="[${GREEN}INFO${RESET}]"
export WARN="[${YELLOW}WARN${RESET}]"
export ERROR="[${RED}ERROR${RESET}]"

RED() { echo -e "\033[31m\033[01m$1\033[0m"; }
GREEN() { echo -e "\033[32m\033[01m$1\033[0m"; }
YELLOW() { echo -e "\033[33m\033[01m$1\033[0m"; }
BLUE() { echo -e "\033[36m\033[01m$1\033[0m"; }

WHITE() { echo -e "\033[37m\033[01m$1\033[0m"; }
READP() { read -p "$(YELLOW "$1")" $2; }

NOTE() { echo -e "${NOTE} ${1}"; }
INFO() { echo -e "${INFO} ${1}"; }
WARN() { echo -e "${WARN} ${1}"; }
ERROR() { echo -e "${ERROR} ${1}"; }

export -f RED GREEN YELLOW BLUE WHITE READP NOTE INFO WARN ERROR PM

PM() {
    if command -v apt &>/dev/null; then
        apt $@
    elif command -v apt-get &>/dev/null; then
        apt-get $@
    elif command -v yum &>/dev/null; then
        yum $@
    elif command -v pacman &>/dev/null; then
        pacman $@
    elif command -v dnf &>/dev/null; then
        dnf $@
    elif command -v snap &>/dev/null; then
        snap $@
    elif command -v yay &>/dev/null; then
        yay $@
    elif command -v zypper &>/dev/null; then
        zypper $@
    elif command -v brew &>/dev/null; then
        brew $@
    elif command -v flatpak &>/dev/null; then
        flatpak $@
    elif command -v port &>/dev/null; then
        port $@
    elif command -v conda &>/dev/null; then
        conda $@
    elif command -v nix &>/dev/null; then
        nix $@
    else
        echo "Package manager not supported on this system."
    fi
}
export -f PM

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
        if pacman -Ss "$package_name" | grep -q "$package_name"; then
            echo "Installing $package_name using pacman."
            sudo pacman -S --noconfirm "$package_name"
            return
        else
            echo "Package '$package_name' not found in pacman repository."
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
        sudo apt remove --purge -y "$package_name" || true
    elif command -v apt-get &>/dev/null; then
        # 使用 apt-get
        sudo apt-get remove --purge -y "$package_name" || true
    elif command -v yum &>/dev/null; then
        # 使用 yum
        sudo yum remove -y "$package_name" || true
    elif command -v pacman &>/dev/null; then
        # 使用 pacman
        sudo pacman -R --noconfirm "$package_name" || true
    fi

    if command -v dnf &>/dev/null; then
        # 使用 dnf
        sudo dnf remove -y "$package_name" || true
    fi

    if command -v snap &>/dev/null; then
        # 使用 snap
        sudo snap remove "$package_name" --purge || true
    fi

    if command -v yay &>/dev/null; then
        # 使用 yay
        sudo yay -R --noconfirm "$package_name" || true
    fi

    if command -v zypper &>/dev/null; then
        # 使用 zypper
        sudo zypper remove -y "$package_name" || true
    fi

    if command -v brew &>/dev/null; then
        # 使用 brew
        sudo brew uninstall "$package_name" || true
    fi

    if command -v flatpak &>/dev/null; then
        # 使用 flatpak
        sudo flatpak uninstall "$package_name" || true
    fi

    if command -v port &>/dev/null; then
        # 使用 port
        sudo port uninstall "$package_name" || true
    fi

    if command -v conda &>/dev/null; then
        # 使用 conda
        sudo conda remove "$package_name" || true
    fi

    if command -v nix &>/dev/null; then
        # 使用 nix
        sudo nix-env -e "$package_name" || true
    fi

}

pm_install() {
    for package_name in $@; do
        pm_install_one "$package_name"
    done
}

pm_uninstall() {
    for package_name in $@; do
        pm_uninstall_one "$package_name"
    done
    hash -r
}

export -f pm_install pm_uninstall pm_install_one pm_uninstall_one

if [ "$(PM -v)" == 'not supported.' ]; then
    ERROR "脚本不支持当前的系统，请选择使用Ubuntu,Debian,Centos系统。" && exit
fi

INFO "ENV PM: $(PM -v)"

export TIMEZONE=$(timedatectl | grep "Time zone" | awk '{print $3}')
INFO "ENV TIMEZONE: ${TIMEZONE}"

export VIRT=$(systemd-detect-virt)
INFO "ENV VIRT: ${VIRT}"

get_os_info() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME="${ID^}"
        OS_VERSION="${VERSION_ID}"
    elif grep -q -i "alpine" /etc/issue; then
        OS_NAME="Alpine"
        OS_VERSION=$(awk '{print $2}' /etc/issue)
    elif grep -q -i "debian" /etc/issue; then
        OS_NAME="Debian"
        OS_VERSION=$(awk '{print $2}' /etc/issue)
    elif grep -q -i "ubuntu" /etc/issue; then
        OS_NAME="Ubuntu"
        OS_VERSION=$(awk '{print $2}' /etc/issue)
    elif grep -q -i "centos|red hat|redhat" /etc/issue; then
        OS_NAME="Centos"
        OS_VERSION=$(awk '{print $2}' /etc/issue)
    elif grep -q -i "arch" /etc/issue; then
        OS_NAME="Arch Linux"
        OS_VERSION=$(awk '{print $2}' /etc/issue)
    elif grep -q -i "opensuse" /etc/issue; then
        OS_NAME="openSUSE"
        OS_VERSION=$(awk '{print $2}' /etc/issue)
    elif grep -q -i "fedora" /etc/issue; then
        OS_NAME="Fedora"
        OS_VERSION=$(awk '{print $2}' /etc/issue)
    elif grep -q -i "debian" /proc/version; then
        OS_NAME="Debian"
        OS_VERSION=$(awk '{print $3}' /proc/version)
    elif grep -q -i "ubuntu" /proc/version; then
        OS_NAME="Ubuntu"
        OS_VERSION=$(awk '{print $3}' /proc/version)
    elif grep -q -i "centos|red hat|redhat" /proc/version; then
        OS_NAME="Centos"
        OS_VERSION=$(awk '{print $3}' /proc/version)
    elif grep -q -i "arch" /proc/version; then
        OS_NAME="Arch Linux"
        OS_VERSION=$(awk '{print $3}' /proc/version)
    elif grep -q -i "opensuse" /proc/version; then
        OS_NAME="openSUSE"
        OS_VERSION=$(awk '{print $3}' /proc/version)
    elif grep -q -i "fedora" /proc/version; then
        OS_NAME="Fedora"
        OS_VERSION=$(awk '{print $3}' /proc/version)
    else
        OS_NAME="Unknown"
        OS_VERSION="Unknown"
    fi

    if [[ "$OS_NAME" == "Unknown" || "$OS_VERSION" == "Unknown" ]]; then
        ERROR "Unknown OS. Please use Ubuntu, Debian, CentOS, openSUSE, Arch Linux" && exit 1
    fi

    echo "$OS_NAME $OS_VERSION"
}
export -f get_os_info

export OS_INFO=$(get_os_info)
export OS_NAME=$(echo "$OS_INFO" | cut -d' ' -f1)
export OS_VERSION=$(echo "$OS_INFO" | cut -d' ' -f2)

INFO "ENV OS_INFO: $OS_INFO"
INFO "ENV OS_NAME: ${OS_NAME}"
INFO "ENV OS_VERSION: ${OS_VERSION}"

export LANG=en_US.UTF-8
export DATA=${DATA:-/opt/data}
export TEMP=${TEMP:-/opt/tmp}

INFO "ENV LANG: ${LANG}"
INFO "ENV DATA: ${DATA}"
INFO "ENV TEMP: ${TEMP}"

sudo mkdir -p ${DATA}
sudo mkdir -p ${TEMP}

# 获取第一个有效的 IPv4 地址，排除回环地址和虚拟网卡的地址
export IPV4_LAN=$(ip -4 addr show |
    grep -v '127.0.0.1' |
    grep -v 'docker' |
    grep -v 'veth' |
    grep -v 'br-' |
    grep -v 'tun' |
    grep -v 'tap' |
    grep -v 'docker0' |
    grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+' |
    head -n 1)
INFO "ENV IPV4_LAN: ${IPV4_LAN}"


if [ ! -n "$IPV4_WAN" ]; then
    export IPV4_WAN=$(curl -sfL ifconfig.me --silent --connect-timeout 5 --max-time 5)
fi
if [ ! -n "$IPV4_WAN" ]; then
    export IPV4_WAN=$(curl -sfL 4.ipw.cn --silent --connect-timeout 5 --max-time 5)
fi
if [ ! -n "$IPV4_WAN" ]; then
    export IPV4_WAN=$(curl -sfL https://api.ipify.org?format=text --silent --connect-timeout 5 --max-time 5)
fi
INFO "ENV IPV4_WAN: ${IPV4_WAN}"

export PING_GCR=$(curl -Is http://gcr.io --silent --connect-timeout 2 --max-time 2 | head -n 1)
if echo "$PING_GCR" | grep -q "HTTP/1.1 200 OK"; then
    export HAS_GCR="true"
elif echo "$PING_GCR" | grep -q "HTTP/1.1 301 Moved Permanently"; then
    export HAS_GCR="true"
else
    export HAS_GCR=""
fi
INFO "ENV HAS_GCR: ${HAS_GCR:-"false"}"

export PING_GOOGLE=$(curl -Is http://google.com --silent --connect-timeout 2 --max-time 2 | head -n 1)
if echo "$PING_GOOGLE" | grep -q "HTTP/1.1 200 OK"; then
    export HAS_GOOGLE="true"
elif echo "$PING_GOOGLE" | grep -q "HTTP/1.1 301 Moved Permanently"; then
    export HAS_GOOGLE="true"
else
    export HAS_GOOGLE=""
fi
INFO "ENV HAS_GOOGLE: ${HAS_GOOGLE:-"false"}"

# GHPROXY=${GHPROXY:-https://ghfast.top/}
export GHPROXY=${GHPROXY}
INFO "ENV GHPROXY: ${GHPROXY}"
# CRPROXY=${CRPROXY:-kubesre.xyz}
export CRPROXY=${CRPROXY}
INFO "ENV CRPROXY: ${CRPROXY}"



getarg() {
    local __name=$1
    shift # 去掉第一个参数（即参数名称），剩下的是参数列表
    local __value=""
    local __start=false
    for arg in "$@"; do
        if [[ $arg =~ ^- ]]; then   # 如果是选项参数（以 - 开头）
            local _key="${arg//-/}" # 去掉 - 符号
            if [[ "$_key" == "$__name" ]]; then
                __start=true # 开始收集值
            else
                __start=false # 停止收集值
            fi
        fi

        if [[ ! $arg =~ ^- && $__start == true ]]; then
            __value="$__value $arg" # 收集值
        fi
    done
    echo $__value # 输出收集到的值
}

hasarg() {
    local __name=$1
    shift # 去掉第一个参数（即参数名称），剩下的是参数列表
    local __value=""
    local __start=false
    local __has=false
    for arg in "$@"; do
        if [[ $arg =~ ^- ]]; then   # 如果是选项参数（以 - 开头）
            local _key="${arg//-/}" # 去掉 - 符号
            if [[ "$_key" == "$__name" ]]; then
                __start=true # 开始收集值
                __has=true
                break
            else
                __start=false # 停止收集值
            fi
        fi
    done
    echo $__has
}


export -f getarg
export -f hasarg


add_env() {
    local env_path=$1
    local new_path="export PATH=\$PATH:$1"
    if [ -z "$env_path" ]; then
        ERROR "add env failed for empty path"
        exit 1
    fi
    if [ ! -d "$env_path" ]; then
        mkdir -p "$env_path"
    fi
    for profile_file in ~/.bashrc ~/.profile ~/.bash_profile ~/.zshrc; do
        if [ -f "$profile_file" ] && ! grep -q "$env_path" "$profile_file"; then
            INFO "Adding env [$env_path] to [$profile_file]"
            echo "$new_path" >>"$profile_file"
        else
            INFO "Env [$env_path] already exists in [$profile_file]"
        fi
    done
}


export -f add_env


init() {

    # 检查并更新 apt 系统
    if command -v apt &>/dev/null; then
        echo "Updating and upgrading packages using apt"
        sudo apt update -y
        sudo apt upgrade -y
        sudo apt autoremove -y
    fi

    # 检查并更新 apt-get 系统
    if command -v apt-get &>/dev/null; then
        echo "Updating and upgrading packages using apt-get"
        sudo apt-get update -y
        sudo apt-get upgrade -y
        sudo apt-get autoremove -y
    fi

    # 检查并更新 yum 系统
    if command -v yum &>/dev/null; then
        echo "Updating and upgrading packages using yum"
        sudo yum update -y
        sudo yum install epel-release -y
        sudo yum autoremove -y
    fi

    # 检查并更新 pacman 系统
    if command -v pacman &>/dev/null; then
        echo "Updating and upgrading packages using pacman"
        sudo pacman -Syu --noconfirm
        sudo pacman -Rns $(pacman -Qdtq)
    fi

    # 检查并更新 dnf 系统
    if command -v dnf &>/dev/null; then
        echo "Updating and upgrading packages using dnf"
        dnf install dnf
        sudo dnf update -y
        sudo dnf autoremove -y
    fi

    # 检查并更新 zypper 系统
    if command -v zypper &>/dev/null; then
        echo "Updating and upgrading packages using zypper"
        sudo zypper refresh -y
        sudo zypper update -y
        sudo zypper remove --clean-deps $(zypper packages --orphaned -t package | awk '{print $3}')
    fi

    # 检查并更新 brew 系统
    if command -v brew &>/dev/null; then
        echo "Updating and upgrading packages using brew"
        brew update
        brew upgrade
        brew cleanup
    fi

    # 检查并更新 flatpak 系统
    if command -v flatpak &>/dev/null; then
        echo "Updating and upgrading packages using flatpak"
        sudo flatpak update -y
    fi

    # 检查并更新 port 系统
    if command -v port &>/dev/null; then
        echo "Updating and upgrading packages using port"
        sudo port selfupdate
        sudo port upgrade outdated
    fi

    # 检查并更新 conda 系统
    if command -v conda &>/dev/null; then
        echo "Updating and upgrading packages using conda"
        conda update --all -y
    fi

    # 检查并更新 nix 系统
    if command -v nix &>/dev/null; then
        echo "Updating and upgrading packages using nix"
        nix-channel --update
        nix-env -u '*'
    fi

    # 如果没有找到支持的包管理器
    if ! (command -v apt &>/dev/null || command -v apt-get &>/dev/null || command -v yum &>/dev/null || command -v pacman &>/dev/null || command -v dnf &>/dev/null || command -v zypper &>/dev/null || command -v brew &>/dev/null || command -v flatpak &>/dev/null || command -v port &>/dev/null || command -v conda &>/dev/null || command -v nix &>/dev/null); then
        echo "No supported package manager found on this system."
    fi

    INFO "----------------------------------------------------------"
    INFO "setup system start"
    INFO "----------------------------------------------------------"

    # 设置 swap 为 0 并关闭 swap
    if ! grep -q 'vm.swappiness = 0' /etc/sysctl.conf; then
        echo "vm.swappiness = 0" >>/etc/sysctl.conf
    fi
    swapoff -a && swapon -a
    sysctl -p

    # 关闭 firewalld 服务
    INFO "Stopping and disabling firewalld"
    sudo systemctl stop firewalld.service 2>/dev/null || true
    sudo systemctl disable firewalld.service 2>/dev/null || true
    sudo systemctl status firewalld.service 2>/dev/null || true

    # 配置 transparent hugepages
    INFO "Disabling transparent hugepages"
    echo never >/sys/kernel/mm/transparent_hugepage/enabled
    echo never >/sys/kernel/mm/transparent_hugepage/defrag
    cat /sys/kernel/mm/transparent_hugepage/enabled


    SYSCTL_CONF="/etc/sysctl.conf"

    add_sysctl_param() {
        local param="$1"
        local value="$2"
        if ! grep -q "^${param} *= *" "$SYSCTL_CONF"; then
            echo "${param} = ${value}" >> "$SYSCTL_CONF"
        fi
    }

    # 添加常规参数（逐个判断）
    add_sysctl_param "fs.file-max" 1000000
    add_sysctl_param "net.core.somaxconn" 32768
    add_sysctl_param "net.ipv4.tcp_syncookies" 0
    add_sysctl_param "vm.overcommit_memory" 1
    add_sysctl_param "vm.swappiness" 0

    # 获取主版本+次版本号（如 4.15）
    kernel_version=$(uname -r | cut -d'-' -f1 | cut -d'.' -f1-2)

    # 判断是否支持 net.ipv4.tcp_tw_recycle（< 4.12 的老内核才支持）
    if [[ $(echo "$kernel_version < 4.12" | bc -l) -eq 1 ]]; then
        # 检查内核是否支持该参数
        if sysctl -a 2>/dev/null | grep -q "net.ipv4.tcp_tw_recycle"; then
            add_sysctl_param "net.ipv4.tcp_tw_recycle" 0
        fi
    fi

    # 应用配置
    sysctl -p || true

    # 设置文件描述符限制
    if ! grep -q 'root.*nofile.*1000000' /etc/security/limits.conf; then
        cat <<EOF >>/etc/security/limits.conf
root           soft    nofile         1000000
root           hard    nofile         1000000
root           soft    stack          32768
root           hard    stack          32768
EOF
    fi

    # 加载 br_netfilter 模块，并写入 sysctl 配置
    INFO "Configuring bridge-nf parameters and sysctl tuning"
    modprobe br_netfilter

    local K8S_SYSCTL_CONF="/etc/sysctl.d/k8s.conf"
    cat <<EOF >"$K8S_SYSCTL_CONF"
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
net.core.somaxconn = 32768
vm.swappiness = 0
net.ipv4.tcp_syncookies = 0
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding=1
fs.file-max = 1000000
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 1024
net.ipv4.conf.all.rp_filter = 1
net.ipv4.neigh.default.gc_thresh1 = 80000
net.ipv4.neigh.default.gc_thresh2 = 90000
net.ipv4.neigh.default.gc_thresh3 = 100000
EOF
    sysctl --system

    INFO "----------------------------------------------------------"
    INFO "setup system done"
    INFO "----------------------------------------------------------"

    INFO "----------------------------------------------------------"
    INFO "install tool start"
    INFO "----------------------------------------------------------"

    # 使用 pm_install 统一安装所有工具包
    local packages=(
        curl wget git vim expect openssl iptables python3 qrencode tar zip unzip sed xxd
        pwgen ntp ntpdate ntpstat jq sshpass neofetch irqbalance linux-cpupower systemd rsyslog fail2ban
        snapd net-tools dnsutils cron apache2-utils bind-utils cronie httpd-tools inetutils
    )
    for package in "${packages[@]}"; do
        pm_install "$package" 2>/dev/null || true
    done

    if command -v fail2ban &>/dev/null; then
        sudo systemctl enable --now fail2ban
        sudo systemctl start fail2ban
    fi

    if command -v snapd &>/dev/null; then
        sudo systemctl enable --now snapd.socket
        sudo systemctl enable snapd
        sudo systemctl start snapd
    fi

    add_env "/snap/bin"

    if command -v git &>/dev/null; then
        git config --global credential.helper store
    fi

    # # 配置防火墙规则
    # iptables -P INPUT ACCEPT
    # iptables -P FORWARD ACCEPT
    # iptables -P OUTPUT ACCEPT
    # iptables -F
    # iptables --flush
    # iptables -tnat --flush

    if command -v neofetch &>/dev/null; then
        local MOTD=/etc/motd
        echo -e "" >$MOTD
        echo -e "\e[31m**********************************\e[0m" >>$MOTD
        echo -e "\e[33m\e[05m⚠️⚠️⚠️⚠︎⚠︎⚠︎⚠️⚠️⚠️⚠︎⚠︎⚠︎⚠️⚠️⚠️⚠︎⚠︎⚠︎⚠️⚠️⚠️⚠︎⚠︎⚠︎⚠️⚠️⚠️⚠︎⚠︎⚠︎⚠️⚠️⚠️⚠︎\e[0m" >>$MOTD
        echo -e "\e[31m正式环境, 数据无价, 谨慎操作\e[0m" >>$MOTD
        echo -e "\e[33m\e[05m⚠️⚠️⚠️⚠︎⚠︎⚠︎⚠️⚠️⚠️⚠︎⚠︎⚠︎⚠️⚠️⚠️⚠︎⚠︎⚠︎⚠️⚠️⚠️⚠︎⚠︎⚠︎⚠️⚠️⚠️⚠︎⚠︎⚠︎⚠️⚠️⚠️⚠︎\e[0m" >>$MOTD
        echo -e "\e[31m**********************************\e[0m" >>$MOTD
        echo -e "" >>$MOTD
        local NEOFETCH=/etc/profile.d/neofetch.sh
        echo '' >$NEOFETCH
        echo 'echo "" ' >>$NEOFETCH
        echo 'neofetch' >>$NEOFETCH
        echo 'echo -e "\e[35mIPV4 WAN: \e[36m`curl ifconfig.me --silent`"' >>$NEOFETCH
        echo 'echo -e "\e[31m**********************************" ' >>$NEOFETCH
        echo 'echo -e "\e[0m" ' >>$NEOFETCH
        echo '' >>$NEOFETCH
    fi

    if command -v ntpd &>/dev/null; then
        sudo systemctl start ntpsec || true
        sudo systemctl start ntpd || true
        sudo systemctl enable ntpd || true
        sudo systemctl enable ntpsec || true
    #   sudo systemctl status ntpd
    fi

    if command -v irqbalance &>/dev/null; then
        sudo systemctl enable irqbalance
        sudo systemctl start irqbalance
    fi

    if command -v cpupower &>/dev/null; then
        sudo modprobe acpi_cpufreq || true
        sudo cpupower frequency-set --governor performance || true
    fi

    INFO "----------------------------------------------------------"
    INFO "install tool done"
    INFO "----------------------------------------------------------"

}

export -f init


install_docker() {
 
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
        # NET EXISTS - 检查 scope 是否匹配
        local current_scope
        current_scope=$(sudo docker network inspect "${NETWORK}" --format '{{.Scope}}' 2>/dev/null || echo "")
        
        if [ "${MODE}" = "stack" ] && [ "${current_scope}" = "local" ]; then
            echo "⚠️ 网络 ${NETWORK} scope 为 local，stack 模式需要 swarm scope"
            echo "🔄 正在删除并重建网络..."
            sudo docker network rm "${NETWORK}" || true
            sudo docker network create --driver overlay --attachable "${NETWORK}"
            echo "✅ 网络已重建为 overlay (swarm scope)"
        elif [ "${MODE}" = "compose" ] && [ "${current_scope}" = "swarm" ]; then
            echo "ℹ️ 网络 ${NETWORK} scope 为 swarm，compose 模式仍可使用"
        else
            echo "✅ docker 网络已存在，scope: ${current_scope}"
        fi
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
}

export -f install_docker



k8s_export_config() {
    if [ -f "/etc/rancher/k3s/k3s.yaml" ]; then
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    elif [ -f "/var/snap/microk8s/current/credentials/client.config" ]; then
        export KUBECONFIG=/var/snap/microk8s/current/credentials/client.config
    elif [ -f "/var/lib/k0s/pki/admin.conf" ]; then
        export KUBECONFIG=/var/lib/k0s/pki/admin.conf
    elif [ -f "/var/lib/k0s/pki/admin.conf" ]; then
        export KUBECONFIG=/var/lib/k0s/pki/admin.conf
    elif [ -f "/etc/kubernetes/admin.conf" ]; then
        export KUBECONFIG=/etc/kubernetes/admin.conf
    fi

    if [ -n "$KUBECONFIG" ]; then
        INFO "export KUBECONFIG=$KUBECONFIG"
    fi
}
k8s_export_config
export -f k8s_export_config
