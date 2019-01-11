#!/usr/bin/env python

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.

import json
import os


def dump_scriptvars():
    """
    Read the variables passed from the Docker host via the environment
    and create a json file /builds/taskcluster/scriptvars.json containing
    their values.

    The payload script will read this file and recreate the necessary
    environment

    This is necessary due to the fact that taskcluster-worker does not
    pass the environment variables in its environment to its payload
    script.

    """
    names = (
        "TESTDROID_PROJECT_ID",
        "TESTDROID_BUILD_ID",
        "TESTDROID_RUN_ID",
        "HOME",
        "HOSTNAME",
        "TASKCLUSTER_ACCESS_TOKEN",
        "TASKCLUSTER_CLIENT_ID",
        "HOST_IP",
        "DEVICE_NAME",
        "ANDROID_DEVICE",
        "DEVICE_SERIAL",
        "TC_WORKER_GROUP",
        "TC_WORKER_TYPE",
        "DEVICE_IP",
    )
    variables = dict( (k, os.environ[k]) for k in names )

    with open('/builds/taskcluster/scriptvars.json', 'w') as scriptvars:
        scriptvars.write(json.dumps(variables))

def main():
    dump_scriptvars()

if __name__ == "__main__":
    main()
