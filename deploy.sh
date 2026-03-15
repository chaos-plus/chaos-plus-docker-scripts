#!/bin/bash -e


if [ -n "${DEBUG:-}" ]; then
    set -x
fi

set -euo pipefail

export WORK_SPACE=$(pwd)

source env/env.sh
source utils/function.sh
source utils/docker-config.sh


function set_dotenv() {
    local key="${1:-}"
    local value="${2:-}"

    if [ -z "${value}" ]; then
        if [[ "${key}" == *"="* ]]; then
            value="${key#*=}"
            key="${key%%=*}"
        fi
    fi

    # 确保 .env.sh 存在
    [ -f .env.sh ] || touch .env.sh

    # 如果未传入 key，直接返回（只更新 ENV）
    if [ -z "${key}" ]; then
        return 0
    fi

    awk -v key="$key" -v val="$value" '
        BEGIN { re = "^[[:space:]]*(export[[:space:]]+)?" key "="; found=0 }
        $0 ~ re { print "export " key "=" val; found=1; next }
        { print }
        END { if(!found) print "export " key "=" val }
    ' .env.sh > .env.sh.tmp && mv .env.sh.tmp .env.sh
}

function check_init(){
    if [ "${HAS_INIT:-}" == "true" ]; then
        INFO "跳过初始化，已存在 HAS_INIT"
    else
        init
        install_docker

        export HAS_INIT="true"
        set_dotenv "HAS_INIT" "true"
    fi
}

function exec() {
    
    check_init
    create_network compose

    local env1="env/env.sh"
    local env3="env-override/env.${ENV}.sh"
    [ -f "$env1" ] && source ${env1}
    [ -f "$env3" ] && source ${env3}

    INFO "🌎 部署环境: ${ENV}"
    INFO "🌐 主域名: ${DOMAIN:-未配置}"
    if [ -n "${DOMAINS:-}" ]; then
        INFO "🌐 所有域名: ${DOMAINS}"
    else
        NOTE "🌐 所有域名: 未配置"
    fi
    echo ""

    if [ $# -gt 0 ]; then
        SERVICES=("${@:1}")
        # 过滤掉空字符串元素
        local filtered=()
        for s in "${SERVICES[@]}"; do
            [ -n "$s" ] && filtered+=("$s")
        done
        SERVICES=("${filtered[@]}")
    fi

    if [ ${#SERVICES[@]} -eq 0 ]; then
        SERVICES=( $(find ./appstore/ -mindepth 1 -maxdepth 1 -type d -printf '%f\n') )
        ERROR "请配置要部署的服务列表： ${SERVICES[*]}"
        exit 1
    fi

    INFO "📋 将要部署的服务列表: ${SERVICES[*]}"

    # 按顺序部署服务
    for serv in "${SERVICES[@]}"; do #也可以写成for element in ${array[*]}
        cd "$WORK_SPACE"

        echo ""
        BLUE "#####################################################################"
        GREEN "#################### service: ${serv} begin ####################"


        export PULL_MODE=always #always|changed|never - changed: 只在 digest 变化时更新
        export COMPOSE_ARGS="" # --force-recreate

        local env1="env/env.sh"
        local env3="env-override/env.${ENV}.sh"
        [ -f "$env1" ] && source ${env1}
        [ -f "$env3" ] && source ${env3}


        local before1="appstore/${serv}/before.sh"
        local before2="appstore-2/${serv}/before.sh"
        local before3="appstore-override/${serv}/before.sh"
        local before4="appstore-override/${serv}-${ENV}/before.sh"
        local before5="appstore-override/${ENV}/${serv}/before.sh"
        local before6="appstore-override/${ENV}-${serv}/before.sh"

        # before
        [ -f "$before1" ] && source ${before1}
        [ -f "$before2" ] && source ${before2}
        [ -f "$before3" ] && source ${before3}
        [ -f "$before4" ] && source ${before4}
        [ -f "$before5" ] && source ${before5}
        [ -f "$before6" ] && source ${before6}
        # before

        # compose.yml
        local compose1="appstore/${serv}/docker-compose.yml"
        local compose2="appstore-2/${serv}/docker-compose.yml"
        local compose3="appstore-override/${ENV}/${serv}/docker-compose.yml"
        local compose4="appstore-override/${ENV}/${serv}/docker-compose.${ENV}.yml"
        local compose5="appstore-override/${ENV}-${serv}/docker-compose.yml"
        local compose6="appstore-override/${ENV}-${serv}/docker-compose.${ENV}.yml"
        local compose_files=()
        if [ -f "${compose1}" ]; then
            compose_files+=("${compose1}")
        fi
        if [ -f "${compose2}" ]; then
            compose_files+=("${compose2}")
        fi
        if [ -f "${compose3}" ]; then
            compose_files+=("${compose3}")
        fi
        if [ -f "${compose4}" ]; then
            compose_files+=("${compose4}")
        fi
        if [ -f "${compose5}" ]; then
            compose_files+=("${compose5}")
        fi
        if [ -f "${compose6}" ]; then
            compose_files+=("${compose6}")
        fi

        if [ "${#compose_files[@]}" -eq 0 ]; then
            ERROR "missing docker-compose.yml"
        else
            # echo "sudo -E ENV=${ENV} docker-compose --compatibility ${compose} up -d --pull=${PULL_MODE:-missing} ${COMPOSE_ARGS:-}"
            # eval "sudo -E ENV=${ENV} docker-compose --compatibility ${compose} up -d --pull=${PULL_MODE:-missing} ${COMPOSE_ARGS:-}"
            
            # 创建临时合并 compose 文件
            TMP_COMPOSE=".tmp-${serv}.yml"
            rm -f "$TMP_COMPOSE"
            INFO "🔧 合并 compose 文件: ${compose_files[*]}"
            
            
            # 使用 docker compose config 合并和插值 compose 文件
            docker compose ${compose_files[@]/#/-f } config > "$TMP_COMPOSE"

            INFO "🚀 使用 compose 模式部署服务 ${serv}"
            local project_name="${NETWORK:-cloud}-${serv}"
            echo "docker compose -p ${project_name} -f ${TMP_COMPOSE} up -d --pull ${PULL_MODE:-always} ${COMPOSE_ARGS:-}"
           
            docker compose -p "${project_name}" -f "${TMP_COMPOSE}" up -d \
                --pull ${PULL_MODE:-always} \
                --remove-orphans \
                ${COMPOSE_ARGS:-}
        fi
        # compose.yml

        # after
        local after1="appstore/${serv}/after.sh"
        local after2="appstore-2/${serv}/after.sh"
        local after3="appstore-override/${serv}/after.sh"
        local after4="appstore-override/${serv}-${ENV}/after.sh"
        local after5="appstore-override/${ENV}/${serv}/after.sh"
        local after6="appstore-override/${ENV}-${serv}/after.sh"
        [ -f "$after1" ] && source ${after1}
        [ -f "$after2" ] && source ${after2}
        [ -f "$after3" ] && source ${after3}
        [ -f "$after4" ] && source ${after4}
        [ -f "$after5" ] && source ${after5}
        [ -f "$after6" ] && source ${after6}
        # after

        cd $WORK_SPACE
        SUCCESS "#################### service: ${serv} end ####################"
        echo ""
        echo ""
    done
}

# 如果有 .env.sh，就 source 它
if [ -f ".env.sh" ]; then
    source .env.sh
fi

# 如果没有ENV变量，就提示用户输入
if [ -z "${ENV:-}" ];then
    while true; do
        read -p "请输入环境 (debug/release/...): " ENV
        if [ -n "${ENV}" ]; then
            export ENV
            break
        fi
        ERROR "环境不能为空，请重新输入"
    done
fi

set_dotenv ENV "${ENV}"

# 如果有 env.${ENV}.sh，就 source 它
if [ -f "env.${ENV}.sh" ]; then
    source env.${ENV}.sh
fi

exec "$@"