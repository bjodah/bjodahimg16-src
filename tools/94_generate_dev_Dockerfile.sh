#!/bin/bash -xu
# This is getting out of hand, turn this into a Mako template when time permits.

TAG=${1}

ABS_REPO_PATH=$(unset CDPATH && cd "$(dirname "$0")/.." && echo $PWD)
cd "$ABS_REPO_PATH"

APT_PACKAGES=$(cat ./resources-dev/apt_packages.txt)
BLOB_FNAMES=$(cat ./resources-dev/blob_urls.txt | awk '{print $3}')
for FNAME in $BLOB_FNAMES; do
    echo $FNAME
done
BLOBS_MIRROR="http://hera.physchem.kth.se/~repo/bjodahimg16dev/$TAG/blobs"
# The --force-overwrite below is for both python-cython and python3-cython: /usr/bin/cython
read -r -d '' BLOBS_DOWNLOAD_INSTALL <<EOF
    cd /tmp && \\
    for FNAME in $BLOB_FNAMES; do \\
        curl -LOs "$BLOBS_MIRROR/\$FNAME"; \\
    done && \\
    bash miniconda3.sh -b -p /opt/miniconda3 && \\
    tar xjf boost_\*.tar.bz2 -C /opt && cd /opt/boost\*/ && ./bootstrap.sh && ./b2 -j 2 --prefix=\$PWD && \\
    rm $BLOB_FNAMES
EOF

read -r -d '' CLEAN <<EOF
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF


cat <<EOF >bjodahimg16dev-dockerfile/environment/Dockerfile
# DO NOT EDIT, This Dockerfile is generated from ./tools/90_generate_dev_Dockerfile.sh
FROM bjodah/bjodahimg16:v1.3
MAINTAINER Björn Dahlgren <bjodah@DELETEMEgmail.com>
RUN \\
    ${BLOBS_DOWNLOAD_INSTALL} && \\
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add - && \\
    echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-5.0 main" | tee -a /etc/apt/sources.list && \\
    apt-get update && apt-get --quiet --assume-yes --no-install-recommends install ${APT_PACKAGES} && \\
    PATH=/opt/miniconda3/bin:\$PATH conda config --set always_yes yes && \\
    PATH=/opt/miniconda3/bin:\$PATH conda config --set changeps1 no && \\
    PATH=/opt/miniconda3/bin:\$PATH conda config --set show_channel_urls True && \\
    PATH=/opt/miniconda3/bin:\$PATH conda config --add channels conda-forge && \\
    PATH=/opt/miniconda3/bin:\$PATH conda install \\
        conda-build python=3.6 gmp numpy scipy matplotlib cython cmake gsl numba \\
        pytest ipywidgets mpmath xz tk mpfr openssl sundials sympy pip sqlite && \\
    PATH=/opt/miniconda3/bin:\$PATH conda clean -t && \\
    ${CLEAN}
EOF

