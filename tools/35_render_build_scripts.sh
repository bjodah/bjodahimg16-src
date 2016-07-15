#!/bin/bash -ex

ROOT=./deb-buildscripts
SOURCE=$ROOT/deb-pypi.sh.template
rm -f $ROOT/deb-pypi-*.sh
for WILD in 'scipy*' 'Cython*'; do
    DEST=$ROOT/deb-pypi-${WILD::-1}.sh
    sed "s/\$\$WILD/$WILD/" < $SOURCE >$DEST
    chmod +x $DEST
done
