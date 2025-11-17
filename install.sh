
#!/bin/bash -e

set -u -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"


echo "🔄 拉取最新脚本仓库代码..."
git pull --rebase
echo "✅ 代码更新完成"
echo ""

echo "🚀 执行部署脚本..."
bash ./deploy.sh "$@"
echo "✅ 部署脚本执行完成"
 
