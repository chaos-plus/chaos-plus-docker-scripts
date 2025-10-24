#!/bin/bash -e

sudo mkdir -p ${DATA}/acme
sudo mkdir -p ${DATA}/cron

ACME_CRON_DIR=${DATA}/cron
sudo mkdir -p $ACME_CRON_DIR
ACME_CRON_SH=$ACME_CRON_DIR/acme.cron.sh
ACME_CRON_LOG=$ACME_CRON_DIR/acme.cron.log

if [ -z "${DOMAINS}" ]; then
    echo "DOMAINS is empty"
    exit 1
fi

if [ -z "${ACME_DNS}" ]; then
    echo "ACME_DNS is empty"
    exit 1
fi

# if [ -z "${ACME_DNS_ID_NAME}" ]; then
#     echo "ACME_DNS_ID_NAME is empty"
#     exit 1
# fi

# if [ -z "${ACME_DNS_ID_VALUE}" ]; then
#     echo "ACME_DNS_ID_VALUE is empty"
#     exit 1
# fi

if [ -z "${ACME_DNS_KEY_NAME}" ]; then
    echo "ACME_DNS_KEY_NAME is empty"
    exit 1
fi

if [ -z "${ACME_DNS_KEY_VALUE}" ]; then
    echo "ACME_DNS_KEY_VALUE is empty"
    exit 1
fi

sudo cat <<EOF >$ACME_CRON_SH
echo "##############################################################################"
echo "acme.sh exec @ \$(date +%F) \$(date +%T)"
docker run -it --rm \\
    -v "${DATA}/acme":/acme.sh \\
    -e ${ACME_DNS_ID_NAME:-"ACME_DNS_ID_NAME"}="${ACME_DNS_ID_VALUE:-""}" \\
    -e ${ACME_DNS_KEY_NAME:-"ACME_DNS_KEY_NAME"}="${ACME_DNS_KEY_VALUE:-""}" \\
    --net=host  \\
    neilpang/acme.sh:3.0.6 \\
    --register-account -m acme@${DOMAIN} \\
    --set-default-ca --server letsencrypt \\
    --keylength 2048 \\
    --preferred-chain "ISRG Root X1" \\
    --issue --force --debug 2 \\
    --dns ${ACME_DNS}  \\
EOF

for name in ${DOMAINS[*]}; do
    sudo cat <<EOF >>$ACME_CRON_SH
    -d ${name} \\
    -d *.${name} \\
EOF
done

cat <<EOF >>$ACME_CRON_SH
#
ls -al ${DATA}/acme/${DOMAIN}*
#
docker restart traefik 2>/dev/null
#
EOF

sudo chmod +x $ACME_CRON_SH
echo ""
echo "--------------------------------------------------------------------------"
ls -al $ACME_CRON_DIR
echo "--------------------------------------------------------------------------"
cat $ACME_CRON_SH
echo "--------------------------------------------------------------------------"
echo ""

if [ -d "${DATA}/acme/ca" ]; then
    echo "acme data exists, skip"
else
    source $ACME_CRON_SH
fi

echo "--------------------------------------------------------------------------"
ansible localhost -m cron -a "name='acme.cron.sh' state=absent"
ansible localhost -m cron -a "name='acme.cron.sh' job='bash $ACME_CRON_SH > $ACME_CRON_LOG' day=*/7 hour=3 minute=0"
ansible localhost -m raw -a "crontab -l"
echo "--------------------------------------------------------------------------"
