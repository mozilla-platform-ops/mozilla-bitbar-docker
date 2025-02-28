#!/usr/bin/env bash

set -e
set -x

# source common vars
. ./vars.sh

# if --no-cache is passed, pass the arg to the build command
if [ "$1" == "--no-cache" ]; then
  NO_CACHE="--no-cache"
fi

# clean up
docker-clean

# build the docker image
docker build "$NO_CACHE" --platform="$LINUX_PLAT" -t "$DOCKER_IMAGE_NAME" .
