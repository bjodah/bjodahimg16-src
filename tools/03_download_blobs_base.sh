#!/bin/bash -x
if [[ ! -d blobs_download-base/ ]]; then
    mkdir blobs_download-base/
fi
set +e
cd blobs_download-base/
while read LINE; do
    IFS=' ' read -a ARRAY <<< "$LINE"
    URL=${ARRAY[0]}
    MD5=${ARRAY[1]}
    FNAME=${ARRAY[2]}
    curl -LOs $URL -O $FNAME
    echo $MD5 $FNAME | md5sum -c --
done <../resources-base/blob_urls.txt
