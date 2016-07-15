#!/bin/bash -u
TAG=${1}
SERVER=$2
ROOT='~/public_html/bjodahimg16'
ssh $SERVER "mkdir -p $ROOT/$TAG/{dpkg,pypi,blobs}"

for DPKG in $(cat ./resources/dpkg_packages.txt); do
    rsync -aur ./packages/$DPKG $SERVER:$ROOT/$TAG/dpkg/
done

rsync -aur ./pypi_download/ $SERVER:$ROOT/$TAG/pypi
rsync -aur ./blobs_download/ $SERVER:$ROOT/$TAG/blobs
