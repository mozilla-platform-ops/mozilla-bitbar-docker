#!/usr/bin/env bash

set -e
# set -x

# source common vars
. ./vars.sh

# if --no-cache is passed, pass the arg to the build command
if [ "$1" == "--no-cache" ]; then
  NO_CACHE="--no-cache"
fi

# if we're on CircleCI (CIRCLE_BRANCH is defined), do special stuff
if [ -n "$CIRCLE_BRANCH" ]; then
    PLATFORM_ARG=""
else
    # clean up
    docker-clean
    # echo the build command
    set +x
    # set platform arg
    PLATFORM_ARG="--platform=$LINUX_PLAT"
fi

# build the docker image
docker build $NO_CACHE $PLATFORM_ARG -t "$DOCKER_IMAGE_NAME" .
