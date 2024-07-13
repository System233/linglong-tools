#!/bin/bash

ROOT=$(readlink -f $(dirname $0))

PKG_NAME=$1
if [ -z $PKG_NAME ];then
    PKG_NAME=.
    LINGLONG_PKG_NAME=$(basename $(readlink -f $PKG_NAME))
else
    cd $PKG_NAME
    LINGLONG_PKG_NAME=$PKG_NAME
fi

rm *.layer 2>/dev/null
ll-builder export
ll-cli uninstall $LINGLONG_PKG_NAME 2>/dev/null
ll-cli install $LINGLONG_PKG_NAME*_runtime.layer
rm *.layer 2>/dev/null
# ll-cli run $LINGLONG_PKG_NAME
