#!/bin/bash -e
# Modified version of:
# https://github.com/ulikoehler/deb-buildscripts/blob/master/deb-boost.sh
BOOST_FNAME=boost-all_1.61.0.orig.tar.bz2
BOOST_URL=http://downloads.sourceforge.net/project/boost/boost/1.61.0/boost_1_61_0.tar.bz2
BOOST_MD5=6095876341956f65f9d35939ccea1a9f
export DEBVERSION=1.61.0-1

# We assume this script is idempotent and side effects are
# left intact since last invocation:
# BEGIN CAHCE LOGIC
ABS_SCRIPT_DIR=$(unset CDPATH && cd "$(dirname "$0")" && echo $PWD)
SCRIPT_BASE=$(basename $0)
CACHE_BASE=$SCRIPT_BASE.cache
SOURCES="$SCRIPT_BASE $BOOST_FNAME"
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

echo "$BOOST_MD5  $BOOST_FNAME" | md5sum -c -- \
    || wget --quiet $BOOST_URL -O $BOOST_FNAME
echo "$BOOST_MD5  $BOOST_FNAME" | md5sum -c -- || exit 1
mkdir -p deb-boost-build
cd deb-boost-build
rm -rf boost_1_*/
ln -fs ../$BOOST_FNAME .
tar xjvf $BOOST_FNAME
cd boost_1_*
#Build DEB
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
cp LICENSE_*.txt debian/copying
#Create the changelog (no messages needed)
dch --create -v $DEBVERSION --package boost-all ""
#Create copyright file
touch debian
#Create control file
cat > debian/control <<EOF
Source: boost-all
Maintainer: None <none@example.com>
Section: misc
Priority: optional
Standards-Version: 3.9.2
Build-Depends: debhelper (>= 8), cdbs, libbz2-dev, zlib1g-dev

Package: boost-all
Architecture: amd64
Depends: \${shlibs:Depends}, \${misc:Depends}, boost-all (= $DEBVERSION)
Description: Boost library, version $DEBVERSION (shared libraries)

Package: boost-all-dev
Architecture: any
Depends: boost-all (= $DEBVERSION)
Description: Boost library, version $DEBVERSION (development files)

Package: boost-build
Architecture: any
Depends: \${misc:Depends}
Description: Boost Build v2 executable
EOF
#Create rules file
cat > debian/rules <<EOF
#!/usr/bin/make -f
%:
	dh \$@
override_dh_auto_configure:
	./bootstrap.sh
override_dh_auto_build:
	./b2 -j 1 --prefix=`pwd`/debian/boost-all/usr/
override_dh_auto_test:
override_dh_auto_install:
	mkdir -p debian/boost-all/usr debian/boost-all-dev/usr debian/boost-build/usr/bin
	./b2 --prefix=`pwd`/debian/boost-all/usr/ install
	mv debian/boost-all/usr/include debian/boost-all-dev/usr
	cp b2 debian/boost-build/usr/bin
        ./b2 install --prefix=`pwd`/debian/boost-build/usr/ install
EOF
#Create some misc files
echo "8" > debian/compat
mkdir -p debian/source
echo "3.0 (quilt)" > debian/source/format
#Build the package
nice -n19 ionice -c3 debuild -b -us -uc
savehash
