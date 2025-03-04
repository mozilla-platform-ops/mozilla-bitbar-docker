#!/usr/bin/env bash

set -e
# set -x

# source common vars
. ./vars.sh

# see if nc is present
if [ ! -x "$(command -v nc)" ]; then
  echo "nc not found, please install netcat"
  exit 1
fi

# use nc to check if localhost 8123 is up, if not, skip proxy
if $(nc -z localhost 8123 2>/dev/null); then
  echo "* proxy is already up, not starting"
else
  echo "* proxy is not up, starting..."
  # if there is a binary `poliopo` present, start it in the background
  if [ -x "$(command -v polipo2)" ]; then
    mkdir -p /tmp/cache/polipo
    polipo2 diskCacheRoot=/tmp/cache/polipo &
    disown
  else
    echo "polipo2 not found, skipping"
  fi
fi

# see if polipo is up
status=0
nc -v -z localhost 8123 2>/dev/null || status=$?

if [ "$status" == 0 ] ; then
	# polipo is running
	echo "* using proxy"

	proxy_host=host.docker.internal
	export http_proxy="http://localhost:8123"
	export https_proxy="http://localhost:8123"

	HTTP_PROX_LINE="--build-arg http_proxy=http://$proxy_host:8123 --build-arg https_proxy=http://$proxy_host:8123"
else
	# polipo is not running
	echo "* not using proxy"
	HTTP_PROX_LINE=""
fi
echo ""

# if --no-cache is passed, pass the arg to the build command
if [ "$1" == "--no-cache" ]; then
  NO_CACHE="--no-cache"
  echo "setting --no-cache mode"
fi

# if we're on CircleCI (CIRCLE_BRANCH is defined), do special stuff
if [ -n "$CIRCLE_BRANCH" ]; then
    PLATFORM_ARG=""
else
    # clean up
    docker-clean
    # set platform arg
    PLATFORM_ARG="--platform=$LINUX_PLAT"
fi

# set -x
# build the docker image
docker build $HTTP_PROX_LINE $NO_CACHE $PLATFORM_ARG -t "$DOCKER_IMAGE_NAME" .
