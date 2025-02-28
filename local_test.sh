#!/usr/bin/env bash

# we want cleanup to run even if tests failed
# - use true on test cmd
set -e
# set -x

#
# runs inspec tests
#

# source common vars
. ./vars.sh

CONTAINER_NAME="devicepool-inspec-testing"

# if we're on CircleCI (CIRCLE_BRANCH is defined), do special stuff
if [ -n "$CIRCLE_BRANCH" ]; then
    PLATFORM_ARG=""
else
    PLATFORM_ARG="--platform=$LINUX_PLAT"
fi

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

# TODO: run test
inspec exec image_tests -t docker://$CONTAINER_NAME || true

# TODO: tear down
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
