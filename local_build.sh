#!/usr/bin/env bash

set -e
set -x

. ./vars.sh

# ./cleanup.sh
docker-cleanup

docker build --platform="$LINUX_PLAT" -t "$DOCKER_IMAGE_NAME" .
