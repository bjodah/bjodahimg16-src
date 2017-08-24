#!/bin/bash -xu
# This is getting out of hand, turn this into a Mako template when time permits.

TAG=${1}

ABS_REPO_PATH=$(unset CDPATH && cd "$(dirname "$0")/.." && echo $PWD)
cd "$ABS_REPO_PATH"

APT_PACKAGES=$(cat ./resources/apt_packages.txt)
DPKG_PKGS=$(cat ./resources/dpkg_packages.txt | head -c -1)
BLOB_FNAMES=$(cat ./resources/blob_urls.txt | awk '{print $3}')
DPKG_MIRROR="http://hera.physchem.kth.se/~repo/bjodahimg16/$TAG/dpkg"
PYPI_MIRROR="http://hera.physchem.kth.se/~repo/bjodahimg16/$TAG/pypi"
BLOBS_MIRROR="http://hera.physchem.kth.se/~repo/bjodahimg16/$TAG/blobs"
# The --force-overwrite below is for both python-cython and python3-cython: /usr/bin/cython
read -r -d '' DPKG_DOWNLOAD_INSTALL <<EOF
    cd /tmp && \\
    for FNAME in $DPKG_PKGS; do \\
        wget --no-verbose "$DPKG_MIRROR/\$FNAME"; \\
    done && \\
    dpkg -i --force-overwrite $DPKG_PKGS && \\
    rm $DPKG_PKGS
EOF
read -r -d '' BLOBS_DOWNLOAD_INSTALL <<EOF
    cd /tmp && \\
    for FNAME in $BLOB_FNAMES; do \\
        wget --no-verbose "$BLOBS_MIRROR/\$FNAME"; \\
    done && \\
    tar xjf phantomjs.tar.bz2 -C /usr/local/share/ && \\
    ln -s /usr/local/share/phantomjs-*-linux-x86_64/bin/phantomjs /usr/local/bin/ && \\
    rm $BLOB_FNAMES
EOF
read -r -d '' PYPKGS_DOWNLOAD <<EOF
    cd /tmp && \\
    for FNAME in $(cd pypi_download; ls * | tr '\n' ' '); do \\
        wget --quiet $PYPI_MIRROR/\$FNAME -O /tmp/\$FNAME; \\
    done
EOF


read -r -d '' PYPKGS_INSTALL <<EOF
    for PYPKG in $(cat ./resources/python_packages.txt | tr '\n' ' '); do \\
        python2 -m pip install --no-index --find-links file:///tmp/ \$PYPKG; \\
        python3 -m pip install --no-index --find-links file:///tmp/ \$PYPKG; \\
    done && \\
    for PYPKG in $(cat ./resources/python3_packages.txt | tr '\n' ' '); do \\
        python3 -m pip install --no-index --find-links file:///tmp/ \$PYPKG; \\
    done && \\
    for PYPKG in $(cat ./resources/python2_packages.txt | tr '\n' ' '); do \\
        python2 -m pip install --no-index --find-links file:///tmp/ \$PYPKG; \\
    done && \\
    ln -s /usr/local/share/pyphen /usr/share/pyphen && \\
    python2 -m ipykernel install && \\
    python3 -m ipykernel install
EOF
# https://github.com/Kozea/Pyphen/issues/10

read -r -d '' CLEAN <<EOF
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF
read -r -d '' MATPLOTLIB <<EOF
    mkdir -p /root/.config/matplotlib/ && \\
    echo "backend: Agg" > /root/.config/matplotlib/matplotlibrc && \\
    python2 -c "import matplotlib.pyplot as plt" && \\
    python3 -c "import matplotlib.pyplot as plt"
EOF


cat <<EOF >bjodahimg16-dockerfile/environment/Dockerfile
# DO NOT EDIT, This Dockerfile is generated from $0
FROM bjodah/bjodahimg16base:v1.2
MAINTAINER Björn Dahlgren <bjodah@DELETEMEgmail.com>
RUN \\
    apt-get update && apt-get --quiet --assume-yes --no-install-recommends install ${APT_PACKAGES} && \\
    ${CLEAN}
RUN \\
    ${PYPKGS_DOWNLOAD} && \\
    ${PYPKGS_INSTALL} && \\
    ${MATPLOTLIB} && \\
    ${CLEAN}
RUN \\
    ${BLOBS_DOWNLOAD_INSTALL} && \\
    ${CLEAN}
EOF

    # ${DPKG_DOWNLOAD_INSTALL} && \\
