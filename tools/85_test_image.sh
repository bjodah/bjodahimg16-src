#!/bin/bash -x
TAG=${1}
REGISTRY_USER=${2}  # avoid clash with trusted build
DOCKERFILE_NAME=bjodahimg16

absolute_repo_path_x="$(readlink -fn -- "$(dirname $0)/.."; echo x)"
absolute_repo_path="${absolute_repo_path_x%x}"

docker run --name bjodah-bjodahimg16-tests -e TERM -v $absolute_repo_path/tests:/tests:ro \
        $REGISTRY_USER/$DOCKERFILE_NAME:$TAG /tests/run_tests.sh

TEST_EXIT=$(docker wait bjodah-bjodahimg16-tests)
docker rm bjodah-bjodahimg16-tests

if [[ "$TEST_EXIT" != "0" ]]; then
    echo "Tests failed"
    exit 1
fi

cd $absolute_repo_path/tests
rm -f output/main.pdf
PYTHONPATH=$absolute_repo_path/bjodah python -m dockre build --image $REGISTRY_USER/$DOCKERFILE_NAME:$TAG --inp input --out output --cmd "pdflatex main.tex"
if [ ! -f output/main.pdf ]; then
    echo "dockre python module build command broken"
    exit 1
else
    cd -
fi

cat <<EOF
Tests passed


You should now commit the changes to trigger a trusted build:

    $ cd bjodahimg16-dockerfile/
    $ git commit -am 'Updated version'
    $ git push
EOF
