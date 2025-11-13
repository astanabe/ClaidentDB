#!/bin/sh
# Set number of processor cores used for computation
export NCPU=`grep -c processor /proc/cpuinfo`
# Set PREFIX
if test -z $PREFIX; then
PREFIX=/usr/local || exit $?
fi
# Set date
if test -z ${date}; then
date=`TZ=JST-9 date +%Y.%m.%d` || exit $?
fi
# Set PATH
export PATH=$PREFIX/bin:$PREFIX/share/claident/bin:$PATH
# Compress Taxonomy DB
chmod 666 *.taxdb
rm -f templist.txt
for p in `ls *_*_genus.taxdb | grep -P -o '^[^_]+_[^_]+_'`; do ls $p*.taxdb >> templist.txt; done
ls overall_*.taxdb >> templist.txt
tar -c --use-compress-program="xz -T 0 -9e" -f taxdb-0.9.${date}.tar.xz -T templist.txt
rm -f templist.txt
sha256sum taxdb-0.9.${date}.tar.xz > taxdb-0.9.${date}.tar.xz.sha256
