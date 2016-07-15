#!/bin/bash -e
cd $(dirname $0)
for f in test_*; do
    echo "Running: $f"
    ./$f
    echo "Tests passed in: $f"
done
