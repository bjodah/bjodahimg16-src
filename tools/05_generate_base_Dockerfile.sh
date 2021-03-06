#!/bin/bash -xu

TAG=${1}

ABS_REPO_PATH=$(unset CDPATH && cd "$(dirname "$0")/.." && echo $PWD)
cd "$ABS_REPO_PATH"

APT_PACKAGES=$(cat ./resources-base/apt_packages.txt)
BLOB_FNAMES=$(cat ./resources-base/blob_urls.txt | awk '{print $3}')
BLOBS_MIRROR="http://hera.physchem.kth.se/~repo/bjodahimg16base/$TAG/blobs"

read -r -d '' BLOBS_DOWNLOAD_INSTALL <<EOF
    cd /tmp && \\
    for FNAME in $BLOB_FNAMES; do \\
        curl -LOs "$BLOBS_MIRROR/\$FNAME"; \\
    done && \\
    python2 get-pip.py && \\
    python3 get-pip.py && \\
    rm $BLOB_FNAMES
EOF

read -r -d '' CLEAN <<EOF
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF


cat <<EOF >bjodahimg16base-dockerfile/environment/Dockerfile
# DO NOT EDIT, This Dockerfile is generated from ./tools/05_generate_base_Dockerfile.sh
FROM ubuntu:xenial
MAINTAINER Björn Dahlgren <bjodah@DELETEMEgmail.com>
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
RUN apt-get update && \\
    apt-get --quiet --assume-yes install locales && \\
    locale-gen en_US.UTF-8 && \\
    echo "path-exclude /usr/share/doc/*" >/etc/dpkg/dpkg.cfg.d/01_nodoc && \\
    echo "path-include /usr/share/doc/*/copyright" >>/etc/dpkg/dpkg.cfg.d/01_nodoc && \\
    apt-get upgrade && \\
    apt-get --assume-yes --no-install-recommends install ${APT_PACKAGES} && \\
    ${BLOBS_DOWNLOAD_INSTALL} && \\
    ${CLEAN}
EOF
