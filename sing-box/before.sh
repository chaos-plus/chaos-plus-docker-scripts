


#!/bin/bash -e


if [ ! -n "`which sb 2>/dev/null`" ]; then
bash <(wget -qO- https://raw.githubusercontent.com/yonggekkk/sing-box-yg/main/sb.sh)
fi

