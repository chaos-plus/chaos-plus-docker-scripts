#!/bin/bash -e

# sudo mkdir -p ${DATA}/gitea-runner/
# sudo chmod 777 ${DATA}/gitea-runner/

# sudo rm -rf ${DATA}/gitea-runner/config.yaml
# sudo touch ${DATA}/gitea-runner/config.yaml
# docker run --entrypoint="" --rm -it gitea/act_runner:nightly act_runner generate-config > ${DATA}/gitea-runner/config.yaml
# cat ${DATA}/gitea-runner/config.yaml

# if [ -z "${GITEA_RUNNER_REGISTRATION_TOKEN}" ]; then
#     echo "GITEA_RUNNER_REGISTRATION_TOKEN is not set"
#     exit 1
# fi


# 查找服务的实际容器名
get_container_name() {
    local service_name=$1
    # 尝试匹配服务名相关的容器（兼容 compose 和 stack）
    docker ps -a --filter "name=${service_name}" --format "{{.Names}}" | head -n 1
}
GITEA_RUNNER_CONTAINER=$(get_container_name "gitea-runner")
docker rm -f "$GITEA_RUNNER_CONTAINER" || true

