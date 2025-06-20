#!/bin/bash -e


export HOSTNAME=$(hostname)

export NETWORK=traefik

export SERV_NAME=cloud

export TEMP=/opt/tmp
export DATA=/opt/data

mkdir -p ${TEMP}
mkdir -p ${DATA}

export RES_LIMIT_MEM="1024M"
export RES_RESER_MEM="1024M"

export PORT_PROXY=80
export PORT_PROXY_SSL=443
export PORT_PROXY_DASHBOARD=8081

export PORT_MYSQL7=3307
export PORT_MYSQL8=3308

export PORT_REDIS=6379

export PORT_FRPS_BIND=7777

export PORT_PROXY_GH=9511
export PORT_PROXY_CR=9522


export PORT_WORDPRESS=8080


export PORT_GRAFANA=3000
export PORT_ALIST=5244


export PORT_UMAMI=8359
export PORT_WALINE=8360


export PORT_EMQX_MQTT=31883
export PORT_EMQX_MQTT_SSL=38883
export PORT_EMQX_MQTT_WS=38083
export PORT_EMQX_MQTT_WSS=38084
export PORT_EMQX_HTTP=38081
export PORT_EMQX_UI=38089

export PORT_RABBITMQ_EPMD=34369
export PORT_RABBITMQ_AMQP_SSL=35671
export PORT_RABBITMQ_AMQP=35672
#export PORT_RABBITMQ_STOMP=61613
#export PORT_RABBITMQ_STOMP_SSL=61614
#export PORT_RABBITMQ_STOMP_WS=15674
#export PORT_RABBITMQ_MQTT=1883
#export PORT_RABBITMQ_MQTT_SSL=8883
#export PORT_RABBITMQ_MQTT_WS=15675
export PORT_RABBITMQ_UI=35673
export PORT_RABBITMQ_CLUSTER=35674


export PORT_NATS_CLIENT=34222
export PORT_NATS_ROUTE=36222
export PORT_NATS_HTTP=38222

export PORT_NACOS_UI=38844
export PORT_NACOS_HTTP=38848
export PORT_NACOS_GRPC=38849

export PORT_SEATA_CLIENT=37091
export PORT_SEATA_SERVER=38091

export PORT_SENTINEL=38858

export PORT_DTM_UI=36788
export PORT_DTM_HTTP=36789
export PORT_DTM_GRPC=36790


export PORT_BYTEBASE=37777

export PORT_CASDOOR=38899

export PORT_DRAWIO=40001
export PORT_COLLABORA=40002

