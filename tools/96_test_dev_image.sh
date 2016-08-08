#!/bin/bash
TAG=${1:-latest}
REGISTRY_USER=${2}
DOCKERFILE_NAME=bjodahimg16dev
ABS_REPO_PATH=$(unset CDPATH && cd "$(dirname "$0")/.." && echo $PWD)
docker run --name bjodah-bjodahimg16dev-tests -e TERM -v $ABS_REPO_PATH/tests-dev:/tests:ro \
        $REGISTRY_USER/$DOCKERFILE_NAME:$TAG /tests/run_tests.sh
TEST_EXIT=$(docker wait bjodah-bjodahimg16dev-tests)
docker rm bjodah-bjodahimg16dev-tests

if [[ "$TEST_EXIT" != "0" ]]; then
    echo "Tests failed"
    exit 1
fi

cat <<EOF
Tests passed


You should now commit the changes to trigger a trusted build:

    $ cd bjodahimg16dev-dockerfile/
    $ git commit -am 'Updated version'
    $ git push
EOF
