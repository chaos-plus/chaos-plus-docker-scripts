#!/bin/bash -e


if [ -z "${PASSWORD}" ]; then
    echo "PASSWORD is empty"
    exit 1
fi
