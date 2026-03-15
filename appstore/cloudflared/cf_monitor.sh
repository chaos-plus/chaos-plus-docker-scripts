#!/bin/sh

echo "[watchdog] Checking cloudflared containers..."

CONTAINERS=$(docker ps --format '{{.ID}} {{.Names}}')

OLDIFS=$IFS
IFS='
'

for LINE in $CONTAINERS; do
  CID=$(echo "$LINE" | awk '{print $1}')
  NAME=$(echo "$LINE" | awk '{print $2}')

  case "$NAME" in
    *cloudflared-tunnel*)
      echo "[watchdog] Inspecting container $CID ($NAME)"

      LOGS=$(docker logs --tail 10 "$CID" 2>&1)

      echo "$LOGS" | grep 'TLS handshake with edge error' >/dev/null 2>&1 ||
      echo "$LOGS" | grep 'there are no free edge addresses' >/dev/null 2>&1 ||
      echo "$LOGS" | grep 'Serve tunnel error' >/dev/null 2>&1

      if [ $? -eq 0 ]; then
        echo "[watchdog] Error detected, restarting container $CID"
        docker restart "$CID"
      else
        echo "[watchdog] No errors detected in $CID"
      fi
      ;;
  esac
done

IFS=$OLDIFS

echo "[watchdog] Check complete."
