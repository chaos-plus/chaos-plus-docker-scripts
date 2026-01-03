#!/bin/bash -e

# 创建每个副本的数据目录
REPLICAS=${GITEA_RUNNER_REPLICAS:-6}
for i in $(seq 1 $REPLICAS); do
    sudo mkdir -p ${DATA}/gitea-runner-${i}
    sudo chmod 777 ${DATA}/gitea-runner-${i}
done

# sudo rm -rf ${DATA}/gitea-runner/config.yaml
# sudo touch ${DATA}/gitea-runner/config.yaml
# docker run --entrypoint="" --rm -it gitea/act_runner:nightly act_runner generate-config > ${DATA}/gitea-runner/config.yaml
# cat ${DATA}/gitea-runner/config.yaml

# if [ -z "${GITEA_RUNNER_REGISTRATION_TOKEN}" ]; then
#     echo "GITEA_RUNNER_REGISTRATION_TOKEN is not set"
#     exit 1
# fi

