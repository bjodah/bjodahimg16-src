#!/bin/bash -u
TAG=${1}
SERVER=$2
ROOT='~/public_html/bjodahimg16base'
ssh $SERVER "mkdir -p $ROOT/$TAG/{dpkg,pypi,blobs}"
rsync -aur ./blobs_download-base/ $SERVER:$ROOT/$TAG/blobs
