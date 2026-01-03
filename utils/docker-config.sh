#!/bin/bash
# Docker Config 版本化管理工具
# 用于创建带内容哈希的 Docker config，只有配置变化时才创建新版本

# 创建版本化的 Docker config（使用内容哈希）
# 参数：
#   $1 - config 基础名称（如 "prometheus-config"）
#   $2 - 配置文件路径
#   $3 - 保留的历史版本数量（默认 3）
create_versioned_config() {
    local CONFIG_BASE=$1
    local CONFIG_FILE=$2
    local KEEP_COUNT=${3:-3}
    
    if [ -z "${CONFIG_BASE}" ] || [ -z "${CONFIG_FILE}" ]; then
        ERROR "需要提供 config 名称和文件路径" >&2
        return 1
    fi
    
    if [ ! -f "${CONFIG_FILE}" ]; then
        ERROR "配置文件不存在: ${CONFIG_FILE}" >&2
        return 1
    fi
    
    # 生成内容哈希版本（使用 md5 或 sha256）
    local CONFIG_HASH
    if command -v md5sum &>/dev/null; then
        CONFIG_HASH=$(md5sum "${CONFIG_FILE}" | awk '{print $1}' | cut -c1-8)
    elif command -v md5 &>/dev/null; then
        CONFIG_HASH=$(md5 -q "${CONFIG_FILE}" | cut -c1-8)
    else
        # fallback to timestamp if no hash command available
        CONFIG_HASH=$(date +%Y%m%d-%H%M%S)
    fi
    
    local CONFIG_NAME="${CONFIG_BASE}-${CONFIG_HASH}"
    
    # 检查是否已存在相同哈希的 config
    if docker config inspect "${CONFIG_NAME}" >/dev/null 2>&1; then
        NOTE "配置未变化，使用已有版本: ${CONFIG_NAME}" >&2
    else
        INFO "配置已变化，创建新版本: ${CONFIG_NAME}" >&2
        if docker config create "${CONFIG_NAME}" "${CONFIG_FILE}" >/dev/null; then
            SUCCESS "配置创建成功: ${CONFIG_NAME}" >&2
            # 清理旧版本
            cleanup_old_configs "${CONFIG_BASE}" "${KEEP_COUNT}" >&2
        else
            ERROR "配置创建失败" >&2
            return 1
        fi
    fi
    
    # 返回完整的配置名称
    echo "${CONFIG_NAME}"
}

# 清理旧版本的 config
# 参数：
#   $1 - config 基础名称
#   $2 - 保留的版本数量（默认 3）
cleanup_old_configs() {
    local CONFIG_BASE=$1
    local KEEP_COUNT=${2:-3}
    
    NOTE "清理旧版本配置 (保留最新 ${KEEP_COUNT} 个)..."
    
    # 获取所有匹配的 config 并排序，删除旧的
    local OLD_CONFIGS=$(docker config ls --filter "name=${CONFIG_BASE}-" \
        --format "{{.CreatedAt}}\t{{.Name}}" 2>/dev/null | \
        sort -r | \
        tail -n +$((KEEP_COUNT + 1)) | \
        awk '{print $NF}')
    
    if [ ! -z "${OLD_CONFIGS}" ]; then
        echo "${OLD_CONFIGS}" | while read config_name; do
            NOTE "删除旧配置: ${config_name}"
            docker config rm "${config_name}" 2>/dev/null || true
        done
        SUCCESS "清理完成"
    else
        NOTE "无需清理"
    fi
}

# 导出函数供外部调用
export -f create_versioned_config
export -f cleanup_old_configs


function create_network() {
    INFO "🌐 检查 Docker 网络: ${NETWORK:-bridge}"

    # 设置默认值
    NETWORK=${NETWORK:-bridge}
    MODE=${MODE:-${1:-compose}}
    export NETWORK MODE

    # 统一获取当前网络信息（如果存在）
    if sudo docker network inspect "${NETWORK}" >/dev/null 2>&1; then
        current_scope=$(sudo docker network inspect "${NETWORK}" --format '{{.Scope}}' 2>/dev/null || echo "")

        case "${MODE}" in
            stack)
                if [ "${current_scope}" = "local" ]; then
                    WARN "网络 ${NETWORK} scope 为 local, stack 模式需要 swarm scope"
                    INFO "🔄 正在删除并重建网络为 overlay..."
                    sudo docker network rm "${NETWORK}" 2>/dev/null || true
                    if sudo docker network create --driver overlay --attachable "${NETWORK}"; then
                        SUCCESS "网络已重建为 overlay (swarm scope)"
                    else
                        ERROR "重建 overlay 网络失败: ${NETWORK}"
                        return 1
                    fi
                else
                    SUCCESS "docker 网络已存在, scope: ${current_scope:-未知} (stack 模式可用)"
                fi
                ;;
            compose)
                if [ "${current_scope}" = "swarm" ]; then
                    INFO "网络 ${NETWORK} scope 为 swarm, compose 模式仍可使用"
                else
                    SUCCESS "docker 网络已存在, scope: ${current_scope:-未知}"
                fi
                ;;
            *)
                WARN "未知的网络模式: ${MODE}, 按 compose 处理"
                SUCCESS "docker 网络已存在, scope: ${current_scope:-未知}"
                ;;
        esac
        return 0
    fi

    # 网络不存在时创建
    INFO "🚧 docker 网络不存在, 正在创建: ${NETWORK}"

    local network_driver
    local -a network_cmd=(sudo docker network create)

    if [ "${MODE}" = "stack" ]; then
        network_driver="overlay"
        network_cmd+=(--driver "${network_driver}" --attachable)
    else
        network_driver="bridge"
        network_cmd+=(--driver "${network_driver}")
    fi

    network_cmd+=("${NETWORK}")

    if "${network_cmd[@]}"; then
        SUCCESS "docker 网络创建成功: ${NETWORK} (driver=${network_driver})"
    else
        ERROR "docker 网络创建失败: ${NETWORK}"
        return 1
    fi
}

export -f create_network