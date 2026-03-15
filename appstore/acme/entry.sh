#!/bin/bash -e


# 构造初始参数列表
set -- \
  acme.sh \
  --home /acme.sh \
  --register-account \
  -m "acme@$DOMAIN" \
  --set-default-ca \
  --server zerossl \
  --output-insecure \
  --keylength 2048 \
  --issue \
  --force \
  --debug 2 \
  --dns "$ACME_DNS"

# 追加域名参数
for d in $DOMAINS; do
  set -- "$@" -d "$d" -d "*.$d"
done

# 仅在证书不存在时执行
if ! ls /acme.sh/*/fullchain.cer >/dev/null 2>&1; then
  "$@"
fi


echo "tail -f /dev/null; #keep container alive for ofelia job-exec"
tail -f /dev/null