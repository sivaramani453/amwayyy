#!/bin/bash
SERVICE_NAME=docker_agent
SCALE_NUMBER=5
if  [[ -n "$1" ]]; then
    SCALE_NUMBER=$1
fi
EXTRA_KEYS=${@:2}
docker-compose pull
echo Start $SCALE_NUMBER of $SERVICE_NAME with extra keys "$EXTRA_KEYS"
docker-compose up -d $EXTRA_KEYS --scale $SERVICE_NAME=$SCALE_NUMBER
