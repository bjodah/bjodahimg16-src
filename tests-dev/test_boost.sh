#!/bin/bash
if [[ ! -d /opt/boost_1_63_0 ]]; then
    >&2 echo "Could not find directory: boost_1_63_0 under /opt:"
    set -x
    ls -lah /opt
    set +x
    exit 1
fi
