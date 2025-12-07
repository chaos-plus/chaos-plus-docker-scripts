#!/bin/bash -e


# export OSS_ENDPOINT="oss-ap-southeast-3.aliyuncs.com"
# export OSS_REGION="ap-southeast-3"
# export OSS_BUCKET="loki-data"
# export OSS_BUCKET_RULER="loki-ruler"
# export OSS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
# export OSS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"

# 检测使用的存储类型
if [ -n "$OSS_ACCESS_KEY_ID" ] && [ -n "$OSS_SECRET_ACCESS_KEY" ]; then
    STORAGE_TYPE="OSS"
else
    STORAGE_TYPE="Local"
fi

echo "=========================================="
echo "Loki 存储类型: ${STORAGE_TYPE}"
echo "=========================================="

if [ "$STORAGE_TYPE" == "OSS" ]; then
    echo "📦 使用阿里云 OSS 对象存储"
    echo "   Endpoint: ${OSS_ENDPOINT}"
    echo "   Bucket: ${OSS_BUCKET}"
    echo "   Region: ${OSS_REGION}"
    
    # OSS 模式下，只需要创建本地缓存目录
    sudo mkdir -p ${DATA}/loki/{tsdb-index,tsdb-cache,wal,compactor,blooms,rules-temp}
    sudo chmod -R 777 ${DATA}/loki
    
    SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    sudo cp -rf ${SRC_DIR}/loki-config-oss.yaml ${DATA}/loki/loki-config.yaml

    echo ""
    echo "⚠️  重要提示："
    echo "   1. 确保已在阿里云创建 OSS Bucket: ${OSS_BUCKET}"
    echo "   2. 确保 AccessKey 有正确的权限"
    echo "   3. 建议使用内网 Endpoint 降低成本"
    echo ""
    
else
    echo "💾 使用本地文件系统存储"
    
    # 创建完整的 Loki 数据目录结构
    sudo mkdir -p ${DATA}/loki/{chunks,tsdb-index,tsdb-cache,rules,rules-temp,compactor,wal,blooms}
    sudo chmod -R 777 ${DATA}/loki

    SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    sudo cp -rf ${SRC_DIR}/loki-config-local.yaml ${DATA}/loki/loki-config.yaml
    
    echo ""
    echo "⚠️  提示："
    echo "   - 本地存储受限于磁盘容量"
    echo "   - 如需更大容量和高可用，建议切换到 OSS"
    echo "   - 参考: loki/OSS-STORAGE-GUIDE.md"
    echo ""
fi

echo "✅ Loki 初始化完成"
echo "📁 数据路径: ${DATA}/loki"
echo "=========================================="

