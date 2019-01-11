#!/bin/bash

workdir=$(dirname $0)
pushd $workdir

if [[ ! -e build ]]; then
    mkdir build
fi

datelabel=$(date  +%Y%m%dT%H%M%S)
echo $datelabel > version
zip -r build/mozilla-docker-$datelabel.zip . -x \*.git\* -x .dockerignore -x *~ -x build/*
zip -r build/mozilla-docker-$datelabel-public.zip . -x \*.git\* -x .dockerignore -x licenses/* -x *~ -x build/*

popd
