#!/bin/bash -e

echo "=========================================="
echo "  Grafana Alloy 初始化"
echo "=========================================="
echo ""

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

echo "📋 配置信息："
echo "   - 主机名: ${HOSTNAME}"
echo "   - 数据路径: ${DATA}/alloy"
echo "   - Loki URL: ${LOKI_URL:-http://loki:3100/loki/api/v1/push}"
echo "   - Prometheus URL: ${PROMETHEUS_URL:-http://prometheus:9090/api/v1/write}"
echo ""

# 创建 Alloy 数据和配置目录
echo "📁 创建目录结构..."
sudo mkdir -p ${DATA}/alloy
sudo chmod -R 777 ${DATA}/alloy

# 复制配置文件
echo "📝 复制配置文件..."
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo \cp -rf ${SRC_DIR}/config.alloy ${DATA}/alloy/config.alloy

echo ""
echo "✅ Alloy 初始化完成"
echo ""
echo "📌 下一步："
echo "   1. 确保 Loki 服务已启动: docker ps | grep loki"
echo "   2. 为容器添加日志采集标签:"
echo "      labels:"
echo "        - \"logging.enabled=true\""
echo "        - \"app_name=your-app\""
echo ""
echo "   3. 启动后查看日志: docker logs -f alloy"
echo ""
echo "📚 配置说明:"
echo "   - 系统日志: /var/log/syslog, /var/log/auth.log 等"
echo "   - 容器日志: 只采集带 logging.enabled=true 标签的容器"
echo "   - trace_id: 自动从日志中提取，支持分布式追踪"
echo ""
echo "=========================================="

# 导出环境变量供 docker-compose 使用
export LOKI_URL="${LOKI_URL:-http://loki:3100/loki/api/v1/push}"
export PROMETHEUS_URL="${PROMETHEUS_URL:-http://prometheus:9090/api/v1/write}"
