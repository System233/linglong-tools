#!/bin/bash

ROOT=$(readlink -f $(dirname $0))
LINGLONG_WORK_DIR="linglong-build"
PKG_NAME="$1"
LINGLONG_PKG_NAME="${PKG_NAME}.linyaps"
CONVERT_DIR=${LINGLONG_WORK_DIR}/linglong-build/${PKG_NAME}

SRC=${CONVERT_DIR}/package/${LINGLONG_PKG_NAME}/linglong/sources
echo $SRC
cd $SRC

DEPS=$($ROOT/diff-deps.sh "$PKG_NAME")

# 读取替换规则并逐行应用
while IFS=: read -r src dist; do
  # 使用 sed 进行替换， -i 选项用于直接编辑文件
  echo Repl $src $dist
  DEPS=$(echo $DEPS|sed  "s/\b$src\b/$dist/g")
done < "$ROOT/repl.deps"

shift
echo $DEPS $*
for i in $DEPS $*;do apt download $i;done;
