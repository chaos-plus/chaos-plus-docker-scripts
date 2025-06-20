
#!/bin/bash -e


if [ -z "${DOMAIN}" ]; then
    echo "DOMAIN is empty"
    exit 1
fi


################################################
## Traefik
################################################
if [ -d "${DATA}/traefik" ]; then
    echo "traefik data exists, skip"
else
    echo "traefik data lost, create"
fi


mkdir -p ${DATA}/traefik/config/

export TRAEFIX_CONF=${DATA}/traefik/config/
cp -rf ./traefik*.*ml ${TRAEFIX_CONF}

sudo sed -i "s/MY_DOMAIN.key/${DOMAIN}.key/g" `grep MY_DOMAIN -rl ${TRAEFIX_CONF}`

if [ -d "${DATA}/acme/${DOMAIN}_ecc" ]; then
    sudo sed -i "s/MY_DOMAIN/${DOMAIN}_ecc/g" `grep MY_DOMAIN -rl ${TRAEFIX_CONF}`
else
    sudo sed -i "s/MY_DOMAIN/${DOMAIN}/g" `grep MY_DOMAIN -rl ${TRAEFIX_CONF}`
fi

################################################
