#!/bin/bash -xue
TAG=$1
REGISTRY_USER=$2  # avoid clash with trusted build
DOCKERFILE_NAME=bjodahimg16

absolute_repo_path_x="$(readlink -fn -- "$(dirname $0)/.."; echo x)"
absolute_repo_path="${absolute_repo_path_x%x}"
cd "$absolute_repo_path"/bjodahimg16-dockerfile/environment

docker build -t $REGISTRY_USER/$DOCKERFILE_NAME:$TAG . | tee ../../$(basename $0).log
if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
    :
else
    exit 1
fi
