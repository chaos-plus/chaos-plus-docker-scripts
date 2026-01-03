#!/bin/bash -e

echo "=========================================="
echo "  Prometheus 初始化"
echo "=========================================="
echo ""

# 检查必需的环境变量
if [ -z "${TEMP}" ]; then
    echo "❌ 错误: TEMP 环境变量未设置"
    echo "请先执行: source ../env.sh"
    exit 1
fi

if [ -z "${HOSTNAME}" ]; then
    echo "❌ 错误: HOSTNAME 环境变量未设置"
    exit 1
fi

echo "📋 配置信息："
echo "   - 主机名: ${HOSTNAME}"
echo "   - 数据路径: ${TEMP}/prometheus"
echo "   - 保留时间: ${PROMETHEUS_RETENTION:-30d}"
echo "   - HTTP 端口: ${PORT_PROMETHEUS:-9090}"
echo ""

# 创建 Prometheus 数据目录
echo "📁 创建目录结构..."
sudo mkdir -p ${TEMP}/prometheus/data
sudo chmod -R 777 ${TEMP}/prometheus

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 创建版本化 Docker configs
export PROMETHEUS_CONFIG=$(create_versioned_config "prometheus-config" "${SRC_DIR}/prometheus.yml" 3)
[ -f "${SRC_DIR}/alert-rules.yml" ] && export PROMETHEUS_RULES=$(create_versioned_config "prometheus-rules" "${SRC_DIR}/alert-rules.yml" 3)

echo ""
echo "✅ Prometheus 初始化完成"
echo ""
echo "📌 下一步："
echo "   1. 访问 Prometheus UI:"
echo "      http://${HOSTNAME}:${PORT_PROMETHEUS:-9090}"
echo ""
echo "   2. 在 Grafana 中添加 Prometheus 数据源:"
echo "      URL: http://prometheus:9090"
echo ""
echo "   3. Alloy 会自动推送指标到 Prometheus"
echo ""
echo "📚 功能说明:"
echo "   - 接收 Alloy 推送的指标"
echo "   - 支持 PromQL 查询"
echo "   - 数据保留: ${PROMETHEUS_RETENTION:-30d}"
echo "   - 提供 HTTP API 和 Web UI"
echo ""
echo "=========================================="
