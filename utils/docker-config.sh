#!/bin/bash

function create_network() {
    INFO "🌐 检查 Docker 网络: ${NETWORK:-cloud}"

    # 设置默认值
    export NETWORK=${NETWORK:-cloud}
    MODE=${1:-${MODE:-stack}}

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

    # MTU 设置，默认 1400 (保守值，兼容多层封装环境如 VPN/代理)
    # 标准值参考：1500(以太网) - 50(VXLAN) - 50(预留) = 1400
    local network_mtu=${NETWORK_MTU:-1450}
    
    if [ "${MODE}" = "stack" ]; then
        network_driver="overlay"
        network_cmd+=(--driver "${network_driver}" --attachable)
        network_cmd+=(--opt "com.docker.network.driver.mtu=${network_mtu}")
    else
        network_driver="bridge"
        network_cmd+=(--driver "${network_driver}")
        network_cmd+=(--opt "com.docker.network.driver.mtu=${network_mtu}")
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