
#!/bin/bash -e

mkdir -p ${DATA}/gitinsight
cd ${DATA}/gitinsight

touch config.yaml
docker run --rm \
-v $(pwd)/config.yaml:/app/config.yaml \
ghcr.io/robotism/gitinsight:latest \
./gitinsight config gen -f /app/config.yaml 