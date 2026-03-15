#!/bin/bash -e


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


# init_db mysql7 3306 root ${PASSWORD:-} spicedb
init_db mysql8 3306 root ${PASSWORD:-} spicedb

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
