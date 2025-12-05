#!/bin/bash -e

echo "=========================================="
echo "  crproxy 镜像版本解析"
echo "=========================================="
echo ""

# 如果已经通过环境变量指定版本，则不再自动检测
if [ -n "${PROXY_CR_VERSION:-}" ]; then
	echo "已指定 PROXY_CR_VERSION=${PROXY_CR_VERSION}，跳过自动检测"
	exit 0
fi

get_github_release_version() {
	local repo="$1"
	local url=""
	if [[ "$repo" =~ releases/latest ]]; then
		url="https://api.github.com/repos/${repo}"
	else
		url="https://api.github.com/repos/${repo}/releases/latest"
	fi

	local version
	version=$(curl -sfL "$url" 2>/dev/null | grep -oE '"tag_name": "[^"]+"' | head -n1 | cut -d'"' -f4 || true)

	if [ -z "${version}" ]; then
		# 网络或 API 异常时返回空字符串，由调用方决定 fallback
		return 1
	fi

	echo "${version}"
}

DETECTED_VERSION=$(get_github_release_version "DaoCloud/crproxy" || true)

if [ -z "${DETECTED_VERSION}" ]; then
	echo "无法从 GitHub 获取 crproxy 最新版本，将使用 tag: latest"
	export PROXY_CR_VERSION="latest"
else
	export PROXY_CR_VERSION="${DETECTED_VERSION}"
fi

echo "最终使用 crproxy 版本: ${PROXY_CR_VERSION}"