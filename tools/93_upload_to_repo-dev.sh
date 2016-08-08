#!/bin/bash -u
TAG=${1}
SERVER=$2
ROOT='~/public_html/bjodahimg16dev'
ssh $SERVER "mkdir -p $ROOT/$TAG/blobs"
rsync -aur ./blobs_download-dev/ $SERVER:$ROOT/$TAG/blobs
