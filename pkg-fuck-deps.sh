#!/bin/bash


MISSING_SHARED_LIBRARIES=`ll-builder run --exec "pkg-get-deps.sh $@" 2>/dev/null`
if [ -z "$MISSING_SHARED_LIBRARIES" ];then
    echo 找不到缺失库
    exit 1
fi
LIBS=`pkg-search.sh $MISSING_SHARED_LIBRARIES|awk -F: '{print $1}'|sort|uniq`
if [ -z "$LIBS" ];then
    echo 找不到缺失库名称
    exit 1
fi

pkg-add-deps.sh $LIBS
