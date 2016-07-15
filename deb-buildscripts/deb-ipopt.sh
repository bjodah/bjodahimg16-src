#!/bin/bash -e
REPO=http://hera.physchem.kth.se/~repo

IPOPT_VERSION=3.12.5
IPOPT_FNAME=Ipopt-$IPOPT_VERSION.tgz
IPOPT_MD5=be47968fde7761ab609009450247f895
IPOPT_URL=$REPO/$IPOPT_MD5/$IPOPT_FNAME

METIS_FNAME=metis-4.0.3.tar.gz
METIS_MD5=d3848b454532ef18dc83e4fb160d1e10
METIS_URL=$REPO/$METIS_MD5/$METIS_FNAME

MUMPS_FNAME=MUMPS_4.10.0.tar.gz
MUMPS_MD5=959e9981b606cd574f713b8422ef0d9f
MUMPS_URL=$REPO/$MUMPS_MD5/$MUMPS_FNAME

# We assume this script is idempotent and side effects are
# left intact since last invocation:
# BEGIN CAHCE LOGIC
ABS_SCRIPT_DIR=$(unset CDPATH && cd "$(dirname "$0")" && echo $PWD)
SCRIPT_BASE=$(basename $0)
CACHE_BASE=$SCRIPT_BASE.cache
SOURCES="$SCRIPT_BASE"
savehash() {
    cd $ABS_SCRIPT_DIR && md5sum $SOURCES > $CACHE_BASE
}
validhash() {
    cd $ABS_SCRIPT_DIR && md5sum -c $CACHE_BASE >/dev/null 2>&1 && return 0
    return 1
}
if validhash; then
    echo "Valid hash ($ABS_SCRIPT_DIR/$SCRIPT_BASE unchanged, exiting early)"
    exit 0
fi
# END CACHE LOGIC

# Build deb package:
mkdir deb-ipopt-build
cd deb-ipopt-build/

echo "$IPOPT_MD5  $IPOPT_FNAME" | md5sum -c -- || wget --quiet $IPOPT_URL -O $IPOPT_FNAME
tar xzf $IPOPT_FNAME

cd Ipopt-3.12.4/ThirdParty/ 
cd Metis
echo "$METIS_MD5  $METIS_FNAME" | md5sum -c -- || wget --quiet $METIS_URL -O $METIS_FNAME
tar xzf $METIS_FNAME
ln -s metis-4.0.? metis-4.0

cd ../Mumps
echo "$MUMPS_MD5  $MUMPS_FNAME" | md5sum -c -- || wget --quiet $MUMPS_URL -O $MUMPS_FNAME
wget --quiet $REPO/$MUMPS_MD5.sh -O unpack_patch.sh 
bash unpack_patch.sh

cd ../..
mkdir build
cd build/
../configure --prefix /usr/local 
make
checkinstall -D -y --pkgname coinor-libipopt1 --pkgversion $IPOPT_VERSION make install
cp *.deb ../../
cd ../../

savehash
