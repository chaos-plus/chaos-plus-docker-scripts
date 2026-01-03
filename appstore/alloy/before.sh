#!/bin/bash -e


echo "=========================================="
echo "  Grafana Alloy 初始化"
echo "=========================================="
echo ""

sudo mkdir -p ${DATA}/alloy
sudo chmod -R 777 ${DATA}/alloy

# 检查必需的环境变量
if [ -z "${DATA}" ]; then
    echo "❌ 错误: DATA 环境变量未设置"
    echo "请先执行: source ../env.sh"
    exit 1
fi

if [ -z "${HOSTNAME}" ]; then
    echo "❌ 错误: HOSTNAME 环境变量未设置"
    exit 1
fi

# 导出环境变量供 docker-compose 使用
export LOKI_URL="${LOKI_URL:-http://loki:3100/loki/api/v1/push}"
export PROMETHEUS_URL="${PROMETHEUS_URL:-http://prometheus:9090/api/v1/write}"


echo "📋 配置信息："
echo "   - 主机名: ${HOSTNAME}"
echo "   - 数据路径: ${DATA}/alloy"
echo "   - Loki URL: ${LOKI_URL}"
echo "   - Prometheus URL: ${PROMETHEUS_URL}"
echo ""


# 创建版本化配置
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ALLOY_CONFIG=$(create_versioned_config "alloy-config" "${SRC_DIR}/config.alloy" 3)

