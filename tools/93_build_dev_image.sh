#!/bin/bash -x
TAG=${1:-latest}
REGISTRY_USER=${2}
DOCKERFILE_NAME=bjodahimgdev

ABS_REPO_PATH=$(unset CDPATH && cd "$(dirname "$0")/.." && echo $PWD)
cd "$ABS_REPO_PATH"/bjodahimgdev-dockerfile/environment
docker build -t $REGISTRY_USER/$DOCKERFILE_NAME:$TAG . | tee $ABS_REPO_PATH/$(basename $0).log && \
if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
    :
else
    exit 1
fi
