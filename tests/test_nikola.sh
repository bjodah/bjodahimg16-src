#!/bin/bash -e
tmpdir=$(mktemp -d)
trap "rm -r $tmpdir" EXIT SIGINT SIGTERM
cd $tmpdir
nikola init -d -q test
cd test
nikola build
