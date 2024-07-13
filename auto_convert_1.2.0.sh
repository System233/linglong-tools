#!/bin/bash

ROOT=$(readlink -f "$(dirname $0)")
SCRIPT_VERSION=1.2.0
#MATCHED_PICA_VERSION=1.1.1-1
PICA_VERSION=$(dpkg -l linglong-pica |grep "$MATCHED_PICA_VERSION")

## Writeable envs
LINGLONG_WORK_DIR="$ROOT/linglong-build"

## Tools version verify
#if [ "${PICA_VERSION}" == "" ]; then
#  echo "This version of the convert script is unmatched with your local 'linglong-pica!'"
#  echo "Stop building...."
#  echo "按回车退出程序"
#  read nouse
#  exit 1
#else
#  echo "Check passed!"
#fi

## Enviroment check
USER=$(whoami)
ARCH=$(uname -m)
if [ ${ARCH} == "x86_64" ]; then
    arch="amd64"
elif [ ${ARCH} == "aarch64" ]; then
    arch="aarch64"
else
    echo "Unsupported architecture: ${ARCH}"
  echo "按回车退出程序"
  read nouse
    exit 1
fi

if [ ${USER} == "root" ]; then
    echo "Running as root user is not supported!"
  echo "按回车退出程序"
  read nouse
    exit 1
else
    echo "Check passed!"
fi

## Auto generated
#  read -p "请输入玲珑应用包名:" ll_pkgname
PKG_NAME="$1"
LINGLONG_PKG_NAME="${PKG_NAME}.linyaps"



if [ "${PKG_NAME}" = "" ] || [ "${LINGLONG_WORK_DIR}" = "" ]; then
    echo "The string of PKG_NAME and LINGLONG_WORK_DIR could not be blank!"
  echo "按回车退出程序"
  read nouse
    exit 1
else
    echo "Check passed!"
fi

  set -x

# Create linglong-pkg dir
    mkdir -p \
${LINGLONG_WORK_DIR}/linglong-build\
 ${LINGLONG_WORK_DIR}/linglong-deb

## clean old cache
    rm -rf ${LINGLONG_WORK_DIR}/linglong-deb/${PKG_NAME}*
    rm -rf ${LINGLONG_WORK_DIR}/linglong-build/${PKG_NAME}*

## Download deb files
  #cd ${LINGLONG_WORK_DIR}/linglong-deb
  #apt download ${PKG_NAME}

## Create convert workdir
    mkdir -p \
${LINGLONG_WORK_DIR}/linglong-build/${PKG_NAME}

CONVERT_DIR=${LINGLONG_WORK_DIR}/linglong-build/${PKG_NAME}

## Convery
  ll-pica init -w ${CONVERT_DIR} --pi ${LINGLONG_PKG_NAME} --pn ${PKG_NAME} -t repo
  #ll-pica convert -c ${LINGLONG_WORK_DIR}/linglong-deb/${PKG_NAME}*\
# -w ${CONVERT_DIR}
  ll-pica convert -w ${CONVERT_DIR}

## Build
  cd ${CONVERT_DIR}/package/${LINGLONG_PKG_NAME}/
  ll-builder build
  ll-builder export

## Build result verify
  LAYER_STATUS=$(find "${CONVERT_DIR}/package/" -name '*.layer')
if [ "${LAYER_STATUS}" == "" ]; then
  echo "Layer files not existed,building failed"
  echo "按回车退出程序"
  read nouse
  exit 1
else
## Move files
  mv ${CONVERT_DIR}/package/${LINGLONG_PKG_NAME}/*.layer ${CONVERT_DIR}/
  cd ${CONVERT_DIR}/package/${LINGLONG_PKG_NAME}/
fi

## Run Test
  ll-builder run
