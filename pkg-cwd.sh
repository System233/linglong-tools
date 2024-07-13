#!/bin/bash
ROOT=$(readlink -f $(dirname $0))
LINGLONG_WORK_DIR="linglong-build"
PKG_NAME="$1"
LINGLONG_PKG_NAME="${PKG_NAME}.linyaps"
CONVERT_DIR=${LINGLONG_WORK_DIR}/linglong-build/${PKG_NAME}

SRC=${CONVERT_DIR}/package/${LINGLONG_PKG_NAME}
echo $SRC