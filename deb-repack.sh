#!/bin/bash
# https://unix.stackexchange.com/a/745467
DEB_FILE=$1
OUT_FILE=`echo $DEB_FILE|sed -e 's/.deb$/.repack.deb/g'`
echo $DEB_FILE '->' $OUT_FILE
ar x $DEB_FILE
zstd -d < control.tar.zst | xz > control.tar.xz
zstd -d < data.tar.zst | xz > data.tar.xz
ar -m -c -a sdsd "$OUT_FILE" debian-binary control.tar.xz data.tar.xz
rm debian-binary control.tar.xz data.tar.xz control.tar.zst data.tar.zst