#!/bin/bash -uex
TAG=${1}
rsync -aur ./pypi_download_base/ repo@hera:~/public_html/bjodahimgbase/$TAG/pypi
