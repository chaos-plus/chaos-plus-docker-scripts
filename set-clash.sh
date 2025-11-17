#!/bin/bash -e

set -u -o pipefail

echo "=========================================="
echo "  安装 Clash for Linux"
echo "=========================================="
echo ""

GH_PROXY_PREFIX="${GH_PROXY_PREFIX:-https://gh-proxy.com/}"
REPO_URL="${GH_PROXY_PREFIX}https://github.com/nelvko/clash-for-linux-install.git"
REPO_DIR="clash-for-linux-install"

if [ -d "${REPO_DIR}" ]; then
    echo "📁 目录 ${REPO_DIR} 已存在，将尝试更新仓库..."
    cd "${REPO_DIR}"
    if command -v git &>/dev/null; then
        git pull --rebase || echo "⚠️ 更新仓库失败，将继续使用当前版本"
    else
        echo "⚠️ 未找到 git 命令，无法更新仓库"
    fi
else
    if ! command -v git &>/dev/null; then
        echo "❌ 未找到 git 命令，无法克隆 Clash 安装脚本仓库"
        exit 1
    fi
    echo "📥 克隆 Clash 安装脚本仓库..."
    git clone --branch master --depth 1 "${REPO_URL}" "${REPO_DIR}"
    cd "${REPO_DIR}"
fi

echo "🔧 开始执行 Clash 安装脚本..."
sudo bash install.sh
echo "✅ Clash 安装脚本执行完成"