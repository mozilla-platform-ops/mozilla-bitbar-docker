# get sha256 from `docker pull`
FROM ubuntu:22.04@sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e

# controls the version of taskcluster components installed below
ARG TC_VERSION="36.0.0"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    curl \
    dnsutils \
    ffmpeg \
    gettext-base \
    git \
    imagemagick \
    libavcodec-dev \
    libavformat-dev \
    libbz2-dev \
    libcurl4 \
    libcurl4-openssl-dev \
    libffi-dev \
    libgconf-2-4 \
    libgtk-3-0 \
    libopencv-dev \
    libpython3-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libswscale-dev \
    locales \
    net-tools \
    netcat \
    openjdk-17-jdk-headless \
    libjaxb-api-java \
    libjaxb-java \
    python3 \
    python3-pip \
    python3-dev \
    software-properties-common \
    sudo \
    tzdata \
    unzip \
    wget \
    xvfb \
    zip \
    zlib1g-dev \
    zstd

RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt install -y python3.9 python3.9-distutils python3.9-venv python3.9-dev && \
    apt-get clean all -y && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

RUN mkdir /builds && \
    useradd -d /builds/worker -s /bin/bash -m worker

# https://docs.docker.com/samples/library/ubuntu/#locales

WORKDIR /builds/worker
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    mkdir -p \
    android-sdk-linux \
    Documents \
    Downloads \
    Pictures \
    Music \
    Videos \
    bin \
    .cache

# Set variables normally configured at login, by the shells parent process, these
# are taken from GNU su manual
# - PYTHONIOENCODING is set so that unicode characters can be output
#   - see https://bugzilla.mozilla.org/show_bug.cgi?id=1600833

ENV    HOME=/builds/worker \
    SHELL=/bin/bash \
    LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    PATH=$PATH:/builds/worker/bin

# download things
ADD https://nodejs.org/dist/v8.11.3/node-v8.11.3-linux-x64.tar.gz /builds/worker/Downloads
ADD https://dl.google.com/android/android-sdk_r24.3.4-linux.tgz /builds/worker/Downloads
ADD https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip /builds/worker/Downloads
ADD https://github.com/taskcluster/taskcluster/releases/download/v${TC_VERSION}/generic-worker-simple-linux-amd64 /usr/local/bin/generic-worker
ADD https://github.com/taskcluster/taskcluster/releases/download/v${TC_VERSION}/livelog-linux-amd64 /usr/local/bin/livelog
ADD https://github.com/taskcluster/taskcluster/releases/download/v${TC_VERSION}/taskcluster-proxy-linux-amd64 /usr/local/bin/taskcluster-proxy
ADD https://github.com/taskcluster/taskcluster/releases/download/v${TC_VERSION}/start-worker-linux-amd64 /usr/local/bin/start-worker
# robust checkout plugin: update sha1 to latest when building a new image
ADD https://hg.mozilla.org/mozilla-central/raw-file/260e22f03e984e0ced16b6c5ff63201cdef0a1f6/testing/mozharness/external_tools/robustcheckout.py /usr/local/src/robustcheckout.py

# for testing builds (these lines mirror above), copy above artifacts from the downloads dir
# COPY downloads/node-v8.11.3-linux-x64.tar.gz /builds/worker/Downloads
# COPY downloads/android-sdk_r24.3.4-linux.tgz /builds/worker/Downloads
# COPY downloads/sdk-tools-linux-4333796.zip /builds/worker/Downloads
# COPY downloads/generic-worker-simple-linux-amd64 /usr/local/bin/generic-worker
# COPY downloads/livelog-linux-amd64 /usr/local/bin/livelog
# COPY downloads/taskcluster-proxy-linux-amd64 /usr/local/bin/taskcluster-proxy
# COPY downloads/start-worker-linux-amd64 /usr/local/bin/start-worker
# COPY downloads/__init__.py /usr/local/src/robustcheckout.py

# copy stackdriver credentials over
COPY stackdriver_credentials.json /etc/google/stackdriver_credentials.json

COPY .bashrc /root/.bashrc
COPY .bashrc /builds/worker/.bashrc
COPY version /builds/worker/version
COPY taskcluster /builds/taskcluster
COPY licenses /builds/worker/android-sdk-linux/licenses
COPY taskcluster/hgrc /etc/mercurial/hgrc.d/mozilla.rc

# Add entrypoint script
COPY scripts/entrypoint.py /usr/local/bin/entrypoint.py
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/run_gw.py /usr/local/bin/run_gw.py
COPY scripts/tooltool.py /usr/local/bin/tooltool.py

# touch /root/.android/repositories.cfg to suppress warnings that is
# it missing during sdkmanager updates (was in lower block). not
# needed for now, but keeping it here for reference.
#
# RUN mkdir /root/.android && \
#     touch /root/.android/repositories.cfg

# chmod -R root:root /builds since we have to run this as root at
# bitbar. Changing ownership prevents user mismatches when caching pip
# installs.

ENV ANDROID_SDK_ROOT=/builds/worker/android-sdk-linux
# to handle https://issuetracker.google.com/issues/327026299 issues for now
#   symptom: `adb devices` issues like:
#     usb_libusb.cpp:944 failed to register inotify watch on '/dev/bus/usb/006/', falling back to sleep: No such file or directory
ENV ADB_LIBUSB=0

ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

# Create a directory for the Android SDK command line tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools

# Change to a temporary working directory
WORKDIR /tmp

# Download the latest command line tools for Linux
#   get latest link from https://developer.android.com/studio#command-line-tools-only
#   - 3/3/2025: aerickson: updated to 11076708, sha256 is 4d6931209eebb1bfb7c7e8b240a6a3cb3ab24479ea294f3539429574b1eec862
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O commandlinetools.zip && \
    unzip commandlinetools.zip -d cmdline-tools && \
    # Move the extracted tools into the proper location
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    mv cmdline-tools/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest/ && \
    rm -rf commandlinetools.zip cmdline-tools

# Accept licenses (this is required for sdkmanager)
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses

# Install the essential SDK packages:
# - platform-tools (which includes adb and fastboot)
# - a specific Android platform (e.g. android-33)
# - build-tools (here version 33.0.0 is used as an example)
RUN ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;35.0.1"

# fix up perms
# cleanup cache dirs
# install nodejs
# install pips
# install cloud logging
RUN cd /tmp && \
    chmod +x /usr/local/bin/generic-worker && \
    chmod +x /usr/local/bin/livelog && \
    chmod +x /usr/local/bin/taskcluster-proxy && \
    chmod +x /usr/local/bin/start-worker && \
    chmod +x /usr/local/bin/tooltool.py && \
    chmod +x /usr/local/bin/entrypoint.* && \
    chmod +x /builds/taskcluster/script.py && \
    chmod 644 /usr/local/src/robustcheckout.py && \
    tar xzf /builds/worker/Downloads/node-v8.11.3-linux-x64.tar.gz -C /usr/local --strip-components 1 && \
    node -v && \
    npm -v && \
    # upgrade the builtin setuptools
    pip3 install setuptools -U && \
    # upgrade six, used by mozdevice
    pip3 install six -U && \
    # pips used by scripts in this docker image
    pip3 install google-cloud-logging && \
    pip3 install mozdevice && \
    # install latest mercurial for py2 and py3
    pip3 install mercurial==5.9.3 && \
    # pips used by jobs
    pip3 install zstandard==0.11.1 && \
    # cleanup
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /builds/worker/Downloads/* && \
    chown -R root:worker /builds && \
    chmod 775 /builds

WORKDIR /builds/worker
ENTRYPOINT ["entrypoint.sh"]
USER worker
