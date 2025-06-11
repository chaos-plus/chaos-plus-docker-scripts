


#!/bin/bash -e

sudo truncate -s 0 /var/log/btmp

if [ ! -n "`which sb 2>/dev/null`" ]; then
bash <(wget -qO- https://raw.githubusercontent.com/yonggekkk/sing-box-yg/main/sb.sh)
fi

