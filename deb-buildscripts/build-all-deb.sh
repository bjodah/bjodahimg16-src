#!/bin/bash -xe
trap "chown -R $HOST_GID:$HOST_UID /build" EXIT SIGINT SIGTERM
if compgen -G "deb-*.sh" > /dev/null; then
    for f in deb-*.sh; do
        ./$f
    done
fi
