#!/bin/bash -xe
trap "chown -R $HOST_GID:$HOST_UID /build" EXIT SIGINT SIGTERM
for f in deb-*.sh; do
    ./$f
done
