#!/bin/bash -e

set -e -u -o pipefail

export WORK_SPACE=$(pwd)

source env/env.sh
source uilts/function.sh

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
        return 0
    fi

    init
    install_docker

    export HAS_INIT="true"
    set_dotenv "HAS_INIT" "true"
    
}

function exec() {
    
    check_init

    local env1="env/env.sh"
    local env3="env-override/env.${ENV}.sh"
    [ -f "$env1" ] && source ${env1}
    [ -f "$env3" ] && source ${env3}

    
    INFO "🌎 部署环境: ${ENV}"
    INFO "🌐 主域名: ${DOMAIN:-未配置}"
    if declare -p DOMAINS >/dev/null 2>&1; then
        INFO "🌐 其他域名: ${DOMAINS[*]}"
    else
        NOTE "🌐 其他域名: 未配置"
    fi
    echo ""

    
    if [ -z "${SERVICES:-}" ]; then
        SERVICES=("${@:1}" )
    fi

    if [ -z "${SERVICES:-}" ]; then
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

        local env1="env/env.sh"
        local env3="env-override/env.${ENV}.sh"
        [ -f "$env1" ] && source ${env1}
        [ -f "$env3" ] && source ${env3}


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
        local compose5="appstore-override/${serv}-${ENV}/docker-compose.${ENV}.yml"
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
        if [ -f "${compose5}" ]; then
            compose="$compose -f ${compose5}"
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
        read -p "请输入环境 (debug/release/...): " ENV
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