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
ENV PATH /opt/miniconda3/bin:\$PATH
RUN \\
    apt-get update && apt-get --quiet --assume-yes install sudo && \\
    ${BLOBS_DOWNLOAD_INSTALL} && \\
    conda config --set always_yes yes && \\
    conda config --set changeps1 no && \\
    conda config --set show_channel_urls True && \\
    conda config --add channels conda-forge && \\
    conda install conda-build python=3.5 gmp numpy scipy matplotlib cython cmake gsl numba pytest ipywidgets mpmath && \\
    python2 -m pip install git+https://github.com/bjodah/cyipopt.git && \\
    python3 -m pip install git+https://github.com/bjodah/cyipopt.git && \\
    conda clean -t && \\
    ${CLEAN}
EOF


    # wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add - && \\
    # echo "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.8 main" | tee -a /etc/apt/sources.list && \\
    # apt-get update && apt-get --quiet --assume-yes --no-install-recommends install ${APT_PACKAGES} && \\


# the last RUN statement contain various fixes...

    # apt-get update && apt-get --quiet --assume-yes -f install libfreetype6-dev libjpeg62 libjpeg62-dev; apt-get -f install && \\
    # ${CLEAN} && \\

#    apt-get update && apt-get --quiet --assume-yes install libsdl2-dev libsdl2-ttf-dev libsdl2-net-dev libsdl2-mixer-dev libsdl2-image-dev libsdl2-gfx-dev && \\
#    ${CLEAN}
