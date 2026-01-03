#!/bin/bash -e

sudo mkdir -p ${DATA}/acme

if [ -z "${DOMAINS:-}" ]; then
    echo "DOMAINS is empty"
    exit 1
fi

# if [ -z "${ACME_DNS:-}" ]; then
#     echo "ACME_DNS is empty"
#     exit 1
# fi

# # if [ -z "${ACME_DNS_ID_NAME}" ]; then
# #     echo "ACME_DNS_ID_NAME is empty"
# #     exit 1
# # fi

# # if [ -z "${ACME_DNS_ID_VALUE}" ]; then
# #     echo "ACME_DNS_ID_VALUE is empty"
# #     exit 1
# # fi

# if [ -z "${ACME_DNS_KEY_NAME:-}" ]; then
#     echo "ACME_DNS_KEY_NAME is empty"
#     exit 1
# fi

# if [ -z "${ACME_DNS_KEY_VALUE:-}" ]; then
#     echo "ACME_DNS_KEY_VALUE is empty"
#     exit 1
# fi

# sudo cat <<EOF >$ACME_CRON_SH
# echo "##############################################################################"
# docker run -it --rm \\
#     -v "${DATA}/acme":/acme.sh \\
#     -e ${ACME_DNS_ID_NAME:-"ACME_DNS_ID_NAME"}="${ACME_DNS_ID_VALUE:-""}" \\
#     -e ${ACME_DNS_KEY_NAME:-"ACME_DNS_KEY_NAME"}="${ACME_DNS_KEY_VALUE:-""}" \\
#     --net=host  \\
#     neilpang/acme.sh:3.0.6 \\
#     --register-account -m acme@${DOMAIN} \\
#     --set-default-ca --server letsencrypt \\
#     --keylength 2048 \\
#     --preferred-chain "ISRG Root X1" \\
#     --issue --force --debug 2 \\
#     --dns ${ACME_DNS}  \\
# EOF

# for name in ${DOMAINS[*]}; do
#     sudo cat <<EOF >>$ACME_CRON_SH
#     -d ${name} \\
#     -d *.${name} \\
# EOF
# done
