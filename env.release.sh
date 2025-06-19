#

export PASSWORD=${PASSWORD:-"12345678"}
export HTPASSWD=$(openssl passwd -apr1 $PASSWORD)

export DOMAINS=("noproxy.top")
export DOMAIN="${DOMAINS[0]}"
export DOMAIN_REGEX=${DOMAIN/./\\.}

export ACME_DNS="dns_namesilo"
export ACME_DNS_ID_NAME=""
export ACME_DNS_ID_VALUE=""
export ACME_DNS_KEY_NAME="Namesilo_Key"
export ACME_DNS_KEY_VALUE="xxxx"

# dns_dp
# export ACME_DNS=${ACME_DNS:-"dns_dp"}
# export ACME_DNS_ID_NAME=${ACME_DNS_ID_NAME:-"DP_Id"}
# export ACME_DNS_ID_VALUE=${ACME_DNS_ID_VALUE:-"xxxx"}
# export ACME_DNS_KEY_NAME=${ACME_DNS_KEY_NAME:-"DP_Key"}
# export ACME_DNS_KEY_VALUE=${ACME_DNS_KEY_VALUE:-"xxxxxxxxx"}

# dns_ali
# export ACME_DNS=${ACME_DNS:-"dns_dp"}
# export ACME_DNS_ID_NAME=${ACME_DNS_ID_NAME:-"Ali_Key"}
# export ACME_DNS_ID_VALUE=${ACME_DNS_ID_VALUE:-"xxxx"}
# export ACME_DNS_KEY_NAME=${ACME_DNS_KEY_NAME:-"Ali_Secret"}
# export ACME_DNS_KEY_VALUE=${ACME_DNS_KEY_VALUE:-"xxxxxxxxx"}
