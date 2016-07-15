#!/bin/bash -u
TAG=${1}
for DPKG in $(cat ./resources/dpkg_packages.txt); do
    rsync -aur ./packages/$DPKG repo@hera.physchem.kth.se:~/public_html/bjodahimg16/$TAG/dpkg/
done

rsync -aur ./pypi_download/ repo@hera.physchem.kth.se:~/public_html/bjodahimg16/$TAG/pypi
rsync -aur ./blobs_download/ repo@hera.physchem.kth.se:~/public_html/bjodahimg16/$TAG/blobs
