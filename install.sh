
#!/bin/bash -e

set -e -u -o pipefail

source ./uilts/function.sh

INFO "🔄 拉取最新脚本仓库代码..."
git pull --rebase
SUCCESS "代码更新完成"
echo ""

INFO "🚀 执行部署脚本..."
bash ./deploy.sh "$@"
SUCCESS "部署脚本执行完成"
 
