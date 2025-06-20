#!/bin/bash -e


sudo mkdir -p ${DATA}/nats

sudo chmod -R 777 ${DATA}/nats


sudo cat > ${DATA}/nats/nats.conf << EOF
port: 4222
http: 8222

server_name: "nats-main"

jetstream {
  store_dir: /data/jetstream
}

cluster {
  name: "NATS"
  listen: "0.0.0.0:6222"

  authorization {
    user: root
    password: ${PASSWORD}
  }
}
EOF