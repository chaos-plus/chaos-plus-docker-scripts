
########################
## MQ
if [ -d "${DATA}/emqx" ]; then
    echo "emqx data exists, skip"
else
    echo "emqx data lost, create"
    
    # 先启动一个临时实例
    docker run -d --name emqx emqx/emqx:5.10
    # 然后拷贝数据到宿主机
    sudo mkdir -p ${DATA}/emqx/data
    sudo chmod -R 777 ${DATA}/emqx

    sudo docker cp emqx:/opt/emqx/data/ ${DATA}/emqx
    sudo docker cp emqx:/opt/emqx/etc/ ${DATA}/emqx
    sudo docker cp emqx:/opt/emqx/log/ ${DATA}/emqx
    
    export EMQX_CONF=${DATA}/emqx/etc/emqx.conf
    sudo echo ''>> ${EMQX_CONF} 
    sudo echo "dashboard.default_username=\"admin\"">> ${EMQX_CONF} 
    sudo echo "dashboard.default_password=\"${PASSWORD}\"">> ${EMQX_CONF} 
    sudo echo ''>> ${EMQX_CONF} 
    sudo cat ${EMQX_CONF} | grep password

    sudo chmod -R 777 ${DATA}/emqx
    
    # 删除临时实例
    docker rm -f emqx
fi


sudo chmod -R 777 ${DATA}/emqx