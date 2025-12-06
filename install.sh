
#!/bin/bash -e

set -e -u -o pipefail


echo "🔄 拉取最新脚本仓库代码..."
git pull --rebase
echo ""

echo "🚀 执行部署脚本..."
bash ./deploy.sh "$@"
echo "部署脚本执行完成"
 
