#!/usr/bin/env bash

set -e
set +x

. ./vars.sh

# docker run -it --entrypoint '/bin/bash' test-docker

root_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -d "$root_dir/tests" ]; then
  TESTDIR_MOUNTPOINT="-v $root_dir/tests:/tests"
fi

SRCDIR_LOCATION="${HOME}/hg/mozilla-source"
if [ -d "$SRCDIR_LOCATION" ]; then
  SRCDIR_MOUNTPOINT="-v ${SRCDIR_LOCATION}:/source"
fi

# TODO: mount mozilla source in
# -v $HOME/hg/mozilla-source:/source

set -x

# --platform=linux/amd64 \
docker run -u root \
  -v "$(pwd)":/work \
  --platform="$LINUX_PLAT" \
  -e DEVICE_NAME='aje-test' \
  -e TC_WORKER_TYPE='gecko-t-ap-test-g5' \
  -e TC_WORKER_GROUP='bitbar' \
  -e TASKCLUSTER_CLIENT_ID='project/autophone/bitbar-x-test-g5' \
  -e TASKCLUSTER_ACCESS_TOKEN='not_a_real_secret' \
  -e gecko_t_ap_test_g5="NOT REAL // pragma: allowlist secret" \
  -e TESTDROID_APIKEY="NOT REAL 2 // pragma: allowlist secret" \
  -it --entrypoint '/bin/bash' \
  ${TESTDIR_MOUNTPOINT:+} \
  ${SRCDIR_MOUNTPOINT:+} \
  "$DOCKER_IMAGE_NAME"
