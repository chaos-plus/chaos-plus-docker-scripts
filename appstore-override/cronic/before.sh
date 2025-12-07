#!/bin/bash -e

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

\cp -rf ${SRC_DIR}/crontab ${DATA}/supercronic