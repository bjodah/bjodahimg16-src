#!/bin/bash -xu
IMAGE=${1:-"bjodah/bjodahimg16base:v1.1"}

absolute_repo_path_x="$(readlink -fn -- "$(dirname $0)/.."; echo x)"
absolute_repo_path="${absolute_repo_path_x%x}"
cd "$absolute_repo_path"

mkdir -p _build/
cp -LRu --preserve=all deb-buildscripts/* _build/
trap "docker rm -f bjodahimg16src-40" INT TERM
docker run --name bjodahimg16src-40 -e TERM -e HOST_UID=$(id -u) -e HOST_GID=$(id -g) -v $absolute_repo_path/_build:/build -w /build $IMAGE /build/build-all-deb.sh | tee $(basename $0).log
BUILD_EXIT=$(docker wait bjodahimg16src-40)
docker rm bjodahimg16src-40
if [[ "$BUILD_EXIT" != "0" ]]; then
    echo "Build failed"
    exit 1
else
    echo "Build succeeded"
    if compgen -G "_build/deb-*-build/*.deb" > /dev/null; then
        PKGS=_build/deb-*-build/*.deb
        echo -n "">./resources/dpkg_packages.txt
        for PKG in $PKGS; do
            echo -n "$(basename $PKG) " >>./resources/dpkg_packages.txt
        done
        if [[ ! -d packages/ ]]; then
            mkdir packages
        fi
        cp $PKGS packages/
    fi
fi
