#!/bin/bash -e

mkdir -p ${DATA}/acme
mkdir -p ${DATA}/cron

ACME_CRON_DIR=${DATA}/cron
mkdir -p $ACME_CRON_DIR
ACME_CRON_SH=$ACME_CRON_DIR/acme.cron.sh
ACME_CRON_LOG=$ACME_CRON_DIR/acme.cron.log

cat <<EOF >$ACME_CRON_SH
echo "##############################################################################"
echo "acme.sh exec @ \$(date +%F) \$(date +%T)"
docker run -it --rm \\
    -v "${DATA}/acme":/acme.sh \\
    -e ${ACME_DNS_ID_NAME:-dns_id}="${ACME_DNS_ID_VALUE}" \\
    -e ${ACME_DNS_KEY_NAME:-dns_key}="${ACME_DNS_KEY_VALUE}" \\
    --net=host  \\
    neilpang/acme.sh:3.0.6 \\
    --register-account -m acme@${DOMAIN} \\
    --set-default-ca --server letsencrypt \\
    --issue --force --debug 2 \\
    --dns ${ACME_DNS:ACME_DNS}  \\
EOF

for name in ${DOMAINS[*]}; do
    cat <<EOF >>$ACME_CRON_SH
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

chmod +x $ACME_CRON_SH
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
