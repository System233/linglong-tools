#!/bin/bash


PKG_NAME=$(echo $1|sed "s/.linyaps//g")
ROOT=$(readlink -f "$(dirname $0)")

$ROOT/pkg-convert.sh "$PKG_NAME"
$ROOT/add-deps.sh "$PKG_NAME" 
PKG_CWD=$($ROOT/pkg-cwd.sh "$PKG_NAME")

cd $PKG_CWD
ll-builder build&&ll-builder run&&ll-builder export
echo CP "$PKG_NAME.linyaps*_runtime.layer"
cp "$PKG_NAME.linyaps*_runtime.layer" /media/sf_VMShared/