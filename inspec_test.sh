#!/usr/bin/env bash

# we want cleanup to run even if tests failed
# - use true on test cmd
set -e
# set -x

. ./vars.sh

name="devicepool-inspec-testing"

# if we're on CircleCI (CIRCLE_BRANCH is defined), do special stuff
if [ -n "$CIRCLE_BRANCH" ]; then
    platform_arg=""
else
    platform_arg="--platform=$LINUX_PLAT"
fi

docker run \
    --name $name \
    $platform_arg \
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
inspec exec image_tests -t docker://$name || true

# TODO: tear down
docker stop $name
docker rm $name
