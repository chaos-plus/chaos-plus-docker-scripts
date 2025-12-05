

export RUNNER_TOKEN=lBA2sbW1eeEGtAY9DII2Zugpiq6vA3VdcoumTku6
export DATA=${DATA:-/opt/data}
export RUNNER_NAME=shared-runner1
docker rm -f ${RUNNER_NAME} || true
docker run -dit \
    --restart=unless-stopped \
    --network=traefik \
    --name ${RUNNER_NAME} \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ${DATA}/${RUNNER_NAME}:/data \
    -e GITEA_INSTANCE_URL=http://gitea:3000 \
    -e GITEA_RUNNER_REGISTRATION_TOKEN=$RUNNER_TOKEN \
    -e GITEA_RUNNER_NAME=$RUNNER_NAME \
    -d docker.io/gitea/act_runner:nightly
docker logs -f ${RUNNER_NAME}