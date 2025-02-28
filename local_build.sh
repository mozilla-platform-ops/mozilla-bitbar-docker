#!/usr/bin/env bash

set -e
set -x

# source common vars
. ./vars.sh

# clean up
docker-clean

# build the docker image
docker build --platform="$LINUX_PLAT" -t "$DOCKER_IMAGE_NAME" .
