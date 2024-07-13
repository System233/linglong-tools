#!/bin/bash
EXPORT_DIR=/media/sf_VMShared
ROOT=$(readlink -f $(dirname $0))

PKG_NAME=$1
if [ -z $PKG_NAME ];then
    PKG_NAME=.
fi

if echo $PKG_NAME|grep -q "\.desktop\$";then
    TARGET=$(grep X-linglong $PKG_NAME|sed -E 's/X-linglong=//g'|head -n 1)
    cd $TARGET
    PKG_NAME=.
    ll-cli uninstall $TARGET
fi
LINGLONG_PKG_NAME=$(basename $(readlink -f $PKG_NAME))

cd $PKG_NAME
rm *.layer 2>/dev/null
ll-builder export
# ll-cli uninstall $LINGLONG_PKG_NAME 2>/dev/null
# ll-cli install $LINGLONG_PKG_NAME*_runtime.layer&&ll-cli run $LINGLONG_PKG_NAME&&cp -va $LINGLONG_PKG_NAME*_runtime.layer $EXPORT_DIR
cp -va $LINGLONG_PKG_NAME*_runtime.layer $EXPORT_DIR
rm *.layer