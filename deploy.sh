#!/bin/bash -e

set -e -u -o pipefail

export WORK_SPACE=$(pwd)

source ./uilts/function.sh

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

    # 处理传入的 key/value，支持新增或更新
    if grep -qE "^\s*${key}=" .env.sh; then
        sed -i.bak "s#^\s*${key}=.*#${key}=${value}#" .env.sh
    else
        echo "${key}=${value}" >> .env.sh
    fi
}

function check_init(){
    if [ "${HAS_INIT:-}" == "true" ]; then
        INFO "跳过初始化，已存在 HAS_INIT"
        return 0
    fi

    init
    install_docker

    export HAS_INIT="true"
    set_dotenv "HAS_INIT" "true"
    
}

function exec() {
    
    check_init

    INFO "🌎 部署环境: ${ENV}"
    INFO "🌐 主域名: ${DOMAIN}"
    if declare -p DOMAINS >/dev/null 2>&1; then
        INFO "🌐 其他域名: ${DOMAINS[*]}"
    else
        NOTE "🌐 其他域名: (未配置)"
    fi
    echo ""

    if [ -z "${SERVICES:-}" ]; then
        SERVICES=("${@:1}" )
    fi

    if [ -z "${SERVICES:-}" ]; then
        SERVICES=( $(find . -maxdepth 1 -type d -not -name '.*' -printf '%f\n') )
        exit 1
    fi

    INFO "📋 将要部署的服务列表: ${SERVICES[*]}"



    # 按顺序部署服务
    for serv in "${SERVICES[@]}"; do #也可以写成for element in ${array[*]}
        cd "$WORK_SPACE"

        if [ ! -d "${serv}" ]; then
            WARN "service ${serv} not found"
            continue
        fi

        if [[ "$serv" == "."* || "$serv" == "-"* ]]; then
            NOTE "service ${serv} ignored"
            continue
        fi



        echo ""
        BLUE "#####################################################################"
        GREEN "#################### service: ${serv} begin ####################"


        local env1="env/env.sh"
        local env2="env-2/${serv}/env.sh"
        local env3="env-override/${serv}/env.sh"

        local before1="appstore/${serv}/before.sh"
        local before2="appstore-2/${serv}/before.sh"
        local before3="appstore-override/${serv}/before.sh"
        local before4="appstore-override/${serv}-${ENV}/before.sh"

        # before
        [ -f "$before1" ] && source ${before1}
        [ -f "$before2" ] && source ${before2}
        [ -f "$before3" ] && source ${before3}
        [ -f "$before4" ] && source ${before4}
        # before

        # compose.yml
        local compose1="appstore/${serv}/docker-compose.yml"
        local compose2="appstore-2/${serv}/docker-compose.yml"
        local compose3="appstore-override/${serv}/docker-compose.yml"
        local compose4="appstore-override/${serv}-${ENV}/docker-compose.yml"
        local compose=""
        if [ -f "${compose1}" ]; then
            compose="$compose -f ${compose1}"
        fi
        if [ -f "${compose2}" ]; then
            compose="$compose -f ${compose2}"
        fi
        if [ -f "${compose3}" ]; then
            compose="$compose -f ${compose3}"
        fi
        if [ -f "${compose4}" ]; then
            compose="$compose -f ${compose4}"
        fi
        if [ -z "${compose}" ]; then
            ERROR "missing docker-compose.yml"
        else
            eval "sudo -E ENV=${ENV} docker-compose --compatibility ${compose} up -d"
        fi
        # compose.yml

        # after
        local after1="appstore/${serv}/after.sh"
        local after2="appstore-2/${serv}/after.sh"
        local after3="appstore-override/${serv}/after.sh"
        local after4="appstore-override/${serv}-${ENV}/after.sh"
        [ -f "$after1" ] && source ${after1}
        [ -f "$after2" ] && source ${after2}
        [ -f "$after3" ] && source ${after3}
        [ -f "$after4" ] && source ${after4}
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
        read -p "请输入环境 (debug/prod): " ENV
        if [ -n "${ENV}" ]; then
            export ENV
            break
        fi
        ERROR "环境不能为空，请重新输入"
    done
fi

set_dotenv ENV ${ENV}

# 如果有 env.${ENV}.sh，就 source 它
if [ -f "env.${ENV}.sh" ]; then
    source env.${ENV}.sh
fi

exec $@