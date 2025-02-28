#!/usr/bin/env bash

set -e
set -x

# source common vars
. ./vars.sh

# if --no-cache is passed, pass the arg to the build command
if [ "$1" == "--no-cache" ]; then
  NO_CACHE="--no-cache"
fi

# if CIRCLE_BRANCH is defined, have a special if block
if [ -n "$CIRCLE_BRANCH" ]; then
    docker build "$NO_CACHE" -t "$DOCKER_IMAGE_NAME" .
else
    # clean up
    docker-clean
    # build the docker image
    docker build "$NO_CACHE" --platform="$LINUX_PLAT" -t "$DOCKER_IMAGE_NAME" .
fi
