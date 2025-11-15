#!/bin/bash

# 日志采集系统验证脚本

echo "=========================================="
echo "  日志采集系统验证"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_service() {
    local service=$1
    echo -n "检查 ${service} 服务... "
    
    if docker ps | grep -q ${service}; then
        echo -e "${GREEN}✓ 运行中${NC}"
        return 0
    else
        echo -e "${RED}✗ 未运行${NC}"
        return 1
    fi
}

check_endpoint() {
    local name=$1
    local url=$2
    echo -n "检查 ${name} 端点... "
    
    if curl -s -f ${url} > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 可访问${NC}"
        return 0
    else
        echo -e "${RED}✗ 不可访问${NC}"
        return 1
    fi
}

# 1. 检查服务状态
echo "1. 检查服务状态"
echo "----------------------------------------"
check_service "loki"
LOKI_STATUS=$?
check_service "alloy"
ALLOY_STATUS=$?
echo ""

# 2. 检查端点
echo "2. 检查端点可访问性"
echo "----------------------------------------"
check_endpoint "Loki Ready" "http://localhost:3100/ready"
check_endpoint "Loki Metrics" "http://localhost:3100/metrics"
check_endpoint "Alloy UI" "http://localhost:12345/-/ready"
echo ""

# 3. 检查 Docker 容器标签
echo "3. 检查容器标签配置"
echo "----------------------------------------"
echo "带有 logging.enabled=true 的容器："

LABELED_CONTAINERS=$(docker ps --filter "label=logging.enabled=true" --format "{{.Names}}")

if [ -z "$LABELED_CONTAINERS" ]; then
    echo -e "${YELLOW}⚠ 没有找到带标签的容器${NC}"
    echo "提示：在 docker-compose.yml 中添加以下标签："
    echo '    labels:'
    echo '      - "logging.enabled=true"'
    echo '      - "app_name=your-app"'
else
    echo -e "${GREEN}找到以下容器：${NC}"
    echo "$LABELED_CONTAINERS" | while read container; do
        echo "  - $container"
        
        # 显示容器的标签
        APP_NAME=$(docker inspect $container --format '{{index .Config.Labels "app_name"}}' 2>/dev/null)
        if [ ! -z "$APP_NAME" ]; then
            echo "    app_name: $APP_NAME"
        fi
    done
fi
echo ""

# 4. 测试日志查询
echo "4. 测试 Loki 日志查询"
echo "----------------------------------------"
echo -n "查询系统日志... "

QUERY_RESULT=$(curl -s -G "http://localhost:3100/loki/api/v1/query" \
  --data-urlencode 'query={job="syslog"}' \
  --data-urlencode 'limit=1')

if echo "$QUERY_RESULT" | grep -q '"status":"success"'; then
    echo -e "${GREEN}✓ 成功${NC}"
    
    # 显示日志数量
    STREAM_COUNT=$(echo "$QUERY_RESULT" | grep -o '"result":\[' | wc -l)
    if [ $STREAM_COUNT -gt 0 ]; then
        echo "  发现日志流"
    fi
else
    echo -e "${YELLOW}⚠ 暂无数据（可能需要等待几分钟）${NC}"
fi
echo ""

# 5. 检查 Alloy 发现的目标
echo "5. 检查 Alloy 发现的容器"
echo "----------------------------------------"
if docker exec alloy wget -q -O- http://localhost:12345/-/healthy > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Alloy 健康检查通过${NC}"
    
    # 尝试获取发现的目标数量
    ALLOY_LOGS=$(docker logs alloy 2>&1 | grep -i "discovered\|targets" | tail -5)
    if [ ! -z "$ALLOY_LOGS" ]; then
        echo "最近的发现日志："
        echo "$ALLOY_LOGS" | sed 's/^/  /'
    fi
else
    echo -e "${YELLOW}⚠ 无法访问 Alloy 健康检查${NC}"
fi
echo ""

# 6. 检查日志目录挂载
echo "6. 检查日志目录挂载"
echo "----------------------------------------"
echo -n "检查 /var/log 挂载... "
if docker inspect alloy | grep -q '"/var/log"'; then
    echo -e "${GREEN}✓ 已挂载${NC}"
else
    echo -e "${RED}✗ 未挂载${NC}"
fi

echo -n "检查应用日志目录... "
if docker inspect alloy | grep -q '/opt/data/logs'; then
    echo -e "${GREEN}✓ 已挂载${NC}"
else
    echo -e "${YELLOW}⚠ 未挂载（如需采集文件日志请挂载）${NC}"
fi
echo ""

# 7. 生成测试报告
echo "=========================================="
echo "  验证摘要"
echo "=========================================="

TOTAL_CHECKS=0
PASSED_CHECKS=0

if [ $LOKI_STATUS -eq 0 ]; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

if [ $ALLOY_STATUS -eq 0 ]; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

echo "通过检查: ${PASSED_CHECKS}/${TOTAL_CHECKS}"
echo ""

if [ $LOKI_STATUS -eq 0 ] && [ $ALLOY_STATUS -eq 0 ]; then
    echo -e "${GREEN}✓ 日志采集系统运行正常！${NC}"
    echo ""
    echo "下一步："
    echo "1. 在 Grafana 中添加 Loki 数据源"
    echo "   URL: http://loki:3100"
    echo ""
    echo "2. 查询日志："
    echo "   系统日志: {job=\"syslog\"}"
    echo "   容器日志: {container!=\"\"}"
    echo "   应用日志: {app=\"7link-v2\"}"
    echo ""
    echo "3. 为更多容器添加标签："
    echo "   labels:"
    echo "     - \"logging.enabled=true\""
    echo "     - \"app_name=your-app\""
else
    echo -e "${YELLOW}⚠ 部分服务未运行${NC}"
    echo ""
    echo "故障排查："
    
    if [ $LOKI_STATUS -ne 0 ]; then
        echo "- Loki 未运行，执行: docker logs loki"
        echo "  启动: bash install.sh loki"
    fi
    
    if [ $ALLOY_STATUS -ne 0 ]; then
        echo "- Alloy 未运行，执行: docker logs alloy"
        echo "  启动: bash install.sh alloy"
    fi
fi

echo ""
echo "详细文档："
echo "  - alloy/CONFIG-GUIDE.md"
echo "  - loki/OSS-STORAGE-GUIDE.md"
echo "=========================================="
