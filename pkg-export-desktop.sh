#!/bin/bash
EXPORT_DIR=/media/sf_VMShared
ROOT=$(readlink -f $(dirname $0))

function pkg-export(){
    LINGLONG_PKG_NAME=$1
    echo 正在导出 $LINGLONG_PKG_NAME
    echo $LINGLONG_PKG_NAME >>~/ok.list
    if [ -d $LINGLONG_PKG_NAME ] && [ ! -z $LINGLONG_PKG_NAME ];then
        pkg-export.sh $LINGLONG_PKG_NAME
        ll-cli uninstall $LINGLONG_PKG_NAME&
        echo "导出完成 $LINGLONG_PKG_NAME code=$?"
    else
        echo "导出失败 $LINGLONG_PKG_NAME"
    fi
}
while read -ep "Desktop>" DESKTOP;do
    [ -z $DESKTOP ]&&continue
    DESKTOP=$(echo $DESKTOP|sed "s/'//g")
    LINGLONG_PKG_NAME=$(grep X-linglong $DESKTOP|sed -E 's/X-linglong=//g'|head -n 1)
    pkg-export $LINGLONG_PKG_NAME &
done
