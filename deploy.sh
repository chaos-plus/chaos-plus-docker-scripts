#!/bin/bash -e

set -e -u -o pipefail

export WORK_SPACE=$(pwd)

source ./uilts/function.sh


function exec() {
    
    init

    echo "🌎 部署环境: ${ENV}"
    echo "🌐 主域名: ${DOMAIN}"
    if declare -p DOMAINS >/dev/null 2>&1; then
        echo "🌐 其他域名: ${DOMAINS[*]}"
    else
        echo "🌐 其他域名: (未配置)"
    fi
    echo ""

    if [ -z "${SERVICES:-}" ]; then
        SERVICES=("${@:1}" )
    fi

    if [ -z "${SERVICES:-}" ]; then
        SERVICES=( $(find . -maxdepth 1 -type d -not -name '.*' -printf '%f\n') )
        exit 1
    fi

    echo "📋 将要部署的服务列表: ${SERVICES[*]}"



    # 按顺序部署服务
    for serv in "${SERVICES[@]}"; do #也可以写成for element in ${array[*]}
        cd "$WORK_SPACE"

        if [ ! -d "${serv}" ]; then
            echo "service ${serv} not found"
            continue
        fi

        if [[ "$serv" == "."* || "$serv" == "-"* ]]; then
            echo "service ${serv} ignored"
            continue
        fi



        echo ""
        echo "#####################################################################"
        echo "######################## service: ${serv} begin ########################"


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
        if [ -z "${compose}"]; then
            echo "missing docker-compose.yml"
        elif
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
        echo "######################## service: ${serv} end ########################"
        echo ""
        echo ""
    done
}

if [ -z "${ENV}" ];then
    export ENV=debug
fi

if [ -f ".env.sh" ]; then
    source .env.sh
fi
if [ -f "env.${ENV}.sh" ]; then
    source env.${ENV}.sh
fi

exec $@