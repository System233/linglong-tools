#!/bin/bash

ROOT=$(readlink -f $(dirname $0))

APPEND=
PKG_NAME=
if [ -z "$1" ];then
    LINGLONG_PKG_NAME=$(basename $(readlink -f .))
    PKG_NAME=$(echo "$LINGLONG_PKG_NAME"|sed 's/.linyaps$//g')
    APPEND=$(cat list.deps 2>/dev/null)
    mkdir -p packages 2>/dev/null
    cd packages
    export TARGET_ARCH=`apt-cache show  "$PKG_NAME"|grep -oP 'Architecture:\s*\K\S+'`
fi

CWD=$(pwd)
if [ -z "$DEB_REPO" ];then
  DEB_REPO=~/.packages
fi


mkdir -p $DEB_REPO 2>>/dev/null

DEPS=$($ROOT/diff-deps.sh $PKG_NAME $APPEND $@)
MAX_JOBS=`nproc`
MAX_JOBS=$((MAX_JOBS*2))
cd $DEB_REPO

if [ -z "$TARGET_ARCH" ];then
  TARGET_ARCH=amd64
fi

function download(){
  IFS=: read -r name arch <<<"$1"
  PKG=$1
  if [ -n "TARGET_ARCH" ] && [ -z "$arch" ];then
    arch=$TARGET_ARCH
    PKG=$name:$arch
  fi
  
  if find . -name "${name}_*$arch.deb" -exec false {} + ;then
    apt download $PKG;
  fi
  for i in `find . -name "${name}_*$arch.deb"` `find . -name "${name}_*_all.deb"`;do
     [ ! -e "$CWD/$i" ] && ln -sf "$DEB_REPO/$i" "$CWD/$i" && echo Added $i
  done
}
for i in $DEPS;do
  while [ "$(jobs -p | wc -l)" -ge "$MAX_JOBS" ]; do
        wait -n
  done
  download $i & 
done;
wait
