


sudo mkdir -p ${DATA}/rabbitmq
sudo chmod -R 777 ${DATA}/rabbitmq

if [ -f "${DATA}/rabbitmq/.erlang.cookie" ]; then
    sudo chmod 600 ${DATA}/rabbitmq/.erlang.cookie
fi
