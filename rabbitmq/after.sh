#!/bin/bash -e

set -u -o pipefail

echo "=========================================="
echo "  RabbitMQ 收尾配置"
echo "=========================================="
echo ""

if [ -z "${DATA:-}" ]; then
	echo "❌ 错误: DATA 环境变量未设置"
	exit 1
fi

if ! command -v docker &>/dev/null; then
	echo "❌ 错误: docker 命令未找到"
	exit 1
fi

COOKIE_FILE="${DATA}/rabbitmq/.erlang.cookie"

echo "🔐 检查 Erlang cookie 权限..."
if [ -f "${COOKIE_FILE}" ]; then
	sudo chmod 600 "${COOKIE_FILE}"
	echo "✅ 已设置 cookie 权限为 600"
else
	echo "ℹ️ 未找到 cookie 文件: ${COOKIE_FILE}，跳过权限调整"
fi

echo ""
echo "🔌 检查 RabbitMQ 容器与插件状态..."

# 查找 rabbitmq 服务的实际容器名
get_container_name() {
    local service_name=$1
    docker ps -a --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}

RABBITMQ_CONTAINER=$(get_container_name "rabbitmq")

if [ -n "$RABBITMQ_CONTAINER" ]; then
	if docker exec "$RABBITMQ_CONTAINER" rabbitmq-plugins list | grep -q 'rabbitmq_event_exchange'; then
		echo "✅ 插件 rabbitmq_event_exchange 已启用"
	else
		echo "⚙️ 启用插件 rabbitmq_event_exchange ..."
		docker exec "$RABBITMQ_CONTAINER" rabbitmq-plugins enable rabbitmq_event_exchange
		docker restart "$RABBITMQ_CONTAINER"
		echo "✅ RabbitMQ 已重启，插件启用完成"
	fi
else
	echo "ℹ️ 未检测到名为 rabbitmq 的容器，跳过插件配置"
fi
