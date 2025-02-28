#!/usr/bin/env bash

set -e
# set -x

#
# runs inspec tests
#

# source common vars
. ./vars.sh

CONTAINER_NAME="devicepool-inspec-testing"
# if container exists, stop and remove it
# ignore errors if container doesn't exist
if [ -n "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
    docker stop $CONTAINER_NAME || true
    docker rm $CONTAINER_NAME || true
fi

# if we're on CircleCI (CIRCLE_BRANCH is defined), do special stuff
if [ -n "$CIRCLE_BRANCH" ]; then
    PLATFORM_ARG=""
else
    PLATFORM_ARG="--platform=$LINUX_PLAT"
fi

set -x
docker run \
    --name $CONTAINER_NAME \
    $PLATFORM_ARG \
    -u root \
    -e DEVICE_NAME='aje-test' \
    -e TC_WORKER_TYPE='gecko-t-ap-test-g5' \
    -e TC_WORKER_GROUP='bitbar' \
    -e TASKCLUSTER_CLIENT_ID='project/autophone/bitbar-x-test-g5' \
    -e TASKCLUSTER_ACCESS_TOKEN='not_a_real_secret' \
    -e gecko_t_ap_test_g5="SECRET_SECRET_SECRET_DO NOT LEAK 1" \
    -e TESTDROID_APIKEY="SECRET_SECRET_SECRET_DO NOT LEAK 2" \
    -d -t devicepool
set +x

# if we're on CircleCI (CIRCLE_BRANCH is defined), do special stuff
if [ -n "$CIRCLE_BRANCH" ]; then
    set -x
    # output to junit2 format for CircleCI
    inspec exec image_tests -t docker://$CONTAINER_NAME --reporter cli junit2:.test_output/junit_output
else
    set -x
    # if we're running locally ignore the exit code so we can cleanup'
    # TODO: figure out a more elegant way of handling this
    inspec exec image_tests -t docker://$CONTAINER_NAME || true
fi

# # tear down
# docker stop $CONTAINER_NAME
# docker rm $CONTAINER_NAME
