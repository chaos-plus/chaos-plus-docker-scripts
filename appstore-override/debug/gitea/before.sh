
# https://docs.gitea.com/zh-cn/administration/config-cheat-sheet
# https://github.com/go-gitea/gitea/blob/release/v1.25/custom/conf/app.example.ini


# 创建 Docker config（每次都需要导出变量）
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo \cp -rf ${SRC_DIR}/app.ini ${DATA}/gitea/app.ini
export GITEA_CONFIG=${DATA}/gitea/app.ini
