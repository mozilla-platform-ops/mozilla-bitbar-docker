#!/usr/bin/env bash

set -e
set -x

. ./vars.sh

# ./cleanup.sh
docker-cleanup

docker create --name "$DOCKER_IMAGE_NAME" "$DOCKER_IMAGE_NAME"
