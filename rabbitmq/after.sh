
if [ -f "${DATA}/rabbitmq/.erlang.cookie" ]; then
    sudo chmod 600 ${DATA}/rabbitmq/.erlang.cookie
fi


if [ -n "`docker ps | grep rabbitmq`" ]; then

    if [ -n "`docker exec rabbitmq rabbitmq-plugins list | grep rabbitmq_event_exchange`" ]; then
        echo ""
    else
        #echo "enable rabbitmq_event_exchange"
        docker exec rabbitmq rabbitmq-plugins enable rabbitmq_event_exchange
        docker restart rabbitmq
        echo ""
    fi

fi
