#!/bin/bash -e

set -u -o pipefail

########################
## MQ
## 初始化 EMQX 数据目录和默认控制台账户

echo "=========================================="
echo "  EMQX 数据初始化"
echo "=========================================="
echo ""

if [ -z "${DATA:-}" ]; then
	echo "❌ 错误: DATA 环境变量未设置"
	exit 1
fi

if [ -z "${PASSWORD:-}" ]; then
	echo "❌ 错误: PASSWORD 环境变量未设置"
	exit 1
fi

if ! command -v docker &>/dev/null; then
	echo "❌ 错误: docker 命令未找到，请先安装 Docker"
	exit 1
fi

if [ -d "${DATA}/emqx" ]; then
	echo "✅ emqx data exists, skip"
else
	echo "📁 emqx data lost, create"
	
	# 先启动一个临时实例
	docker run -d --name emqx emqx/emqx:5.8.8
	# 然后拷贝数据到宿主机
    sudo mkdir -p ${DATA}/emqx/data
    sudo chmod -R 777 ${DATA}/emqx

    sudo docker cp emqx:/opt/emqx/data/ ${DATA}/emqx
    sudo docker cp emqx:/opt/emqx/etc/ ${DATA}/emqx
    sudo docker cp emqx:/opt/emqx/log/ ${DATA}/emqx
    
    sudo chmod -R 777 ${DATA}/emqx

    export EMQX_CONF=${DATA}/emqx/etc/emqx.conf
    sudo echo ''>> ${EMQX_CONF} 
    sudo echo "dashboard.default_username=\"admin\"">> ${EMQX_CONF} 
    sudo echo "dashboard.default_password=\"${PASSWORD}\"">> ${EMQX_CONF} 
    sudo echo ''>> ${EMQX_CONF} 
    sudo cat ${EMQX_CONF} | grep password

    sudo chmod -R 777 ${DATA}/emqx
	
	# 删除临时实例
	docker rm -f emqx
fi

