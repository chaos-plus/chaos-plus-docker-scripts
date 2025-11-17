#!/bin/bash -e

set -u -o pipefail

echo "=========================================="
echo "  Spicedb 初始化"
echo "=========================================="
echo ""

# 检查必要的环境变量
if [ -z "${PASSWORD:-}" ]; then
    echo "❌ 错误: PASSWORD 环境变量未设置"
    exit 1
fi

if [ -z "${NETWORK:-}" ]; then
    echo "❌ 错误: NETWORK 环境变量未设置"
    exit 1
fi

if ! command -v docker &>/dev/null; then
    echo "❌ 错误: docker 命令未找到，请先安装 Docker"
    exit 1
fi

echo "📋 使用的配置:"
echo "   - MySQL root 密码: ******"
echo "   - Docker 网络: ${NETWORK}"
echo ""

echo "🗄️ 检查 MySQL 实例并创建 spicedb 数据库..."

if docker ps -a --format '{{.Names}}' | grep -q '^mysql7$'; then
    echo "   - 在 mysql7 中创建/更新 spicedb 数据库..."
    docker exec -i mysql7 mysql -uroot -p"${PASSWORD}" \
        -e "CREATE DATABASE IF NOT EXISTS spicedb DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
fi

if docker ps -a --format '{{.Names}}' | grep -q '^mysql8$'; then
    echo "   - 在 mysql8 中创建/更新 spicedb 数据库..."
    docker exec -i mysql8 mysql -uroot -p"${PASSWORD}" \
        -e "CREATE DATABASE IF NOT EXISTS spicedb DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
fi

echo ""
echo "🔄 执行 Spicedb 数据库迁移..."

export SPICEDB_VERSION="${SPICEDB_VERSION:-latest}"

docker run --rm -i --network "${NETWORK}" authzed/spicedb:"${SPICEDB_VERSION}" \
    datastore migrate head \
    --skip-release-check=true \
    --log-level=debug \
    --datastore-engine=mysql \
    --datastore-conn-uri="root:${PASSWORD}@tcp(mysql8:3306)/spicedb?parseTime=true"

echo "✅ Spicedb 数据库迁移完成"
