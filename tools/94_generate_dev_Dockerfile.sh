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
        wget --no-verbose "$BLOBS_MIRROR/\$FNAME"; \\
    done && \\
    bash miniconda3.sh -b -p /opt/miniconda3 && \\
    rm $BLOB_FNAMES
EOF

read -r -d '' CLEAN <<EOF
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF


cat <<EOF >bjodahimg16dev-dockerfile/environment/Dockerfile
# DO NOT EDIT, This Dockerfile is generated from ./tools/90_generate_dev_Dockerfile.sh
FROM bjodah/bjodahimg16:v1.2
MAINTAINER Björn Dahlgren <bjodah@DELETEMEgmail.com>
RUN \\
    python2 -m pip install --upgrade pip && \\
    python3 -m pip install --upgrade pip && \\
    python2 -m pip install git+https://github.com/bjodah/cyipopt.git && \\
    python3 -m pip install git+https://github.com/bjodah/cyipopt.git && \\
    apt-get update && apt-get --quiet --assume-yes --no-install-recommends install sudo latexmk texlive-math-extra && \\
    ${BLOBS_DOWNLOAD_INSTALL} && \\
    PATH=/opt/miniconda3/bin:\$PATH conda config --set always_yes yes && \\
    PATH=/opt/miniconda3/bin:\$PATH conda config --set changeps1 no && \\
    PATH=/opt/miniconda3/bin:\$PATH conda config --set show_channel_urls True && \\
    PATH=/opt/miniconda3/bin:\$PATH conda config --add channels conda-forge && \\
    PATH=/opt/miniconda3/bin:\$PATH conda install conda-build python=3.5 gmp numpy scipy matplotlib cython cmake gsl numba pytest ipywidgets mpmath xz tk mpfr openssl sundials sympy pip sqlite && \\
    PATH=/opt/miniconda3/bin:\$PATH conda clean -t && \\
    ${CLEAN}
RUN \\
    cd /opt && curl -LOs http://downloads.sourceforge.net/project/boost/boost/1.63.0/boost_1_63_0.tar.bz2 && \\
    echo "1c837ecd990bb022d07e7aab32b09847  boost_1_63_0.tar.bz2" | md5sum -c -- && \\
    tar xjf boost_1_63_0.tar.bz2 && rm boost_1_63_0.tar.bz2
EOF


    # wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add - && \\
    # echo "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.8 main" | tee -a /etc/apt/sources.list && \\
    # apt-get update && apt-get --quiet --assume-yes --no-install-recommends install ${APT_PACKAGES} && \\


# the last RUN statement contain various fixes...

    # apt-get update && apt-get --quiet --assume-yes -f install libfreetype6-dev libjpeg62 libjpeg62-dev; apt-get -f install && \\
    # ${CLEAN} && \\

#    apt-get update && apt-get --quiet --assume-yes install libsdl2-dev libsdl2-ttf-dev libsdl2-net-dev libsdl2-mixer-dev libsdl2-image-dev libsdl2-gfx-dev && \\
#    ${CLEAN}
