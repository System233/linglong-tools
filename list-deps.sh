#!/bin/bash

ROOT=$(readlink -f $(dirname $0))
# DEPS=$(apt-rdepends $* |grep -oP 'Depends: \K\S+'|sort|uniq)

if [ -z "$TARGET_ARCH" ];then
  TARGET_ARCH=amd64
fi
# DEPS=$(LC_ALL=en apt-cache  depends --recurse --no-breaks --no-replaces --no-suggests  --no-recommends  --no-conflicts  --no-enhances  $* |grep -oP 'Depends: \K\S+'|sed -E 's+[<>]++g'|sort|uniq)
DEPS=$(LC_ALL=en apt-cache depends $@ --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances |grep -oP 'Depends:\s*\K\S+'|grep -vP "<|>"|sort -u)

DEPS="$@ $DEPS"
while IFS=: read -r src dist; do
  DEPS=$(echo $DEPS|sed -e "s/$src/$dist/g")
done < $ROOT/repl.deps;

echo $DEPS|xargs -n1 echo|grep -v ":[^$TARGET_ARCH]"

# for i in $DEPS;do
#   if echo $i|grep -vq ":" && [ -n "$TARGET_ARCH" ];then
#     echo $i:$TARGET_ARCH
#   else
#     echo $i
#   fi
# done

