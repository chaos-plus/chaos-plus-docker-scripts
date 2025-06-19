
if [ -f "${DATA}/rabbitmq/.erlang.cookie" ]; then
    sudo chmod 600 ${DATA}/rabbitmq/.erlang.cookie
else
    sudo mkdir -p ${DATA}/rabbitmq
fi
