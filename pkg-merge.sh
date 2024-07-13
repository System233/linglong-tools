#!/bin/bash

ROOT=$(readlink -f $(dirname $0))


DEB_REPO=~/.packages
mkdir -p $DEB_REPO 2>>/dev/null
CWD=$(pwd)

for i in *.deb;do
    if [ ! -h $i ];then
        mv $i $DEB_REPO||rm $i
        ln -s $DEB_REPO/$i $i
    fi
done