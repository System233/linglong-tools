#!/bin/bash

ROOT=$(readlink -f $(dirname $0))

CWD=$(pwd)

if [ ! -z "$1" ];then
    cd "$1"
fi
PS3="结果如何>"
for i in *.layer;do
    PKG_NAME=$(echo $i|grep -oP "\S+?.linyaps")
    if echo $PKG_NAME|grep -q -f test.ok -f test.fail;then
        echo 跳过 $PKG_NAME
        continue
    fi
    echo 正在测试 $PKG_NAME -\> $i
    cp $i /var/tmp/install.layer
    chmod 777 /var/tmp/install.layer
    ll-cli install /var/tmp/install.layer
    rm /var/tmp/install.layer
    #ll-cli run $PKG_NAME
    select choice in "正常" "不正常";do
        case $choice in
            "正常" ) 
            echo $PKG_NAME>>test.ok
            break
            ;;
            "不正常" ) 
            echo $PKG_NAME>>test.fail
            break
            ;;
        esac
    done
    echo 测试完成 $PKG_NAME
    ll-cli uninstall $PKG_NAME
done