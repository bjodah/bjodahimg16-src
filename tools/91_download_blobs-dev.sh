#!/bin/bash -x
if [[ ! -d blobs_download-dev/ ]]; then
    mkdir blobs_download-dev/
fi
set +e
cd blobs_download-dev/
while read LINE; do
    IFS=' ' read -a ARRAY <<< "$LINE"
    URL=${ARRAY[0]}
    MD5=${ARRAY[1]}
    FNAME=${ARRAY[2]}
    wget --quiet $URL -O $FNAME
    echo $MD5 $FNAME | md5sum -c --
done <../resources-dev/blob_urls.txt
