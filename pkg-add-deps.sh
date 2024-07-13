#!/bin/bash
set -e

mkdir -p packages 2>/dev/null

cd packages
PREV=$(ls -l|wc -l)
pull-deps.sh $@
CUR=$(ls -l|wc -l)
if [ $CUR != $PREV ];then
    echo $@|xargs -n 1 echo >> ../list.deps
fi