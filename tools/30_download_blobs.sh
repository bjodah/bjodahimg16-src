#!/bin/bash -x
mkdir -p blobs_download/
set +e
cd blobs_download/
while read LINE; do
    IFS=' ' read -a ARRAY <<< "$LINE"
    URL=${ARRAY[0]}
    MD5=${ARRAY[1]}
    FNAME=${ARRAY[2]}
    wget --quiet $URL -O $FNAME
    echo $MD5 $FNAME | md5sum -c --
done <../resources/blob_urls.txt
