#!/bin/bash
set -e
ROOT=$(readlink -f $(dirname $0))

PKG_NAME=$1
if [ -z $PKG_NAME ];then
    LINGLONG_PKG_NAME=$(basename $(readlink -f .))
    PKG_NAME=$(echo "$LINGLONG_PKG_NAME"|sed 's/.linyaps$//g')
    mkdir -p packages 2>/dev/null
    cd packages
else
  PKG_NAME=$(echo "$PKG_NAME"|sed 's/.linyaps$//g')
  LINGLONG_PKG_NAME="${PKG_NAME}.linyaps"
  mkdir -p $LINGLONG_PKG_NAME/packages 2>/dev/null
  cd $LINGLONG_PKG_NAME/packages
fi


if grep -qF ":i386" ../list.deps;then
  export TARGET_ARCH=i386
fi
#rm *.deb
$ROOT/pull-deps.sh $PKG_NAME $(cat ../list.deps)

dpkg -x $PKG_NAME*.deb ../AppDir


F_DESC=$(dpkg-deb -f $PKG_NAME*.deb Description| sed 's/^\s*/    /g')
F_VER=$(dpkg-deb -f $PKG_NAME*.deb Version)
cd ..

IFS='.+-' read -r -a F_VERS <<< "$F_VER"

for i in {0..3}; do  
  F_VERS[i]=$(echo ${F_VERS[$i]}|sed -e 's/^0//g' -e 's/[^0-9.]//g')
  if [ -z "${F_VERS[$i]}" ]; then
    F_VERS[$i]=0
  fi
done
DESKTOP=app.desktop
DESKTOP_FIND=$(ls AppDir/opt/apps/$PKG_NAME/entries/applications/*.desktop|head -n 1)
if [ -z "$DESKTOP_FIND" ];then
  DESKTOP_FIND=$(ls AppDir/usr/share/applications/*.desktop|head -n 1)
fi

if [ ! -e app.desktop ];then
  if [ -z "$DESKTOP_FIND" ];then
    echo ERROR: Unknown Entry!
  else
    cp $DESKTOP_FIND app.desktop
    rm -rf AppDir
  fi
fi
DESKTOP_NAME=$(basename $DESKTOP_FIND)

echo Desktop=$DESKTOP
echo DesktopFile=$DESKTOP_NAME

F_NAME=$(grep '^Name=' $DESKTOP | sed 's/^Name=//')
F_VER=`echo "${F_VERS[0]}.${F_VERS[1]}.${F_VERS[2]}.${F_VERS[3]}"| sed 's/[^0-9.]//g'`
echo Name=$F_NAME
echo Version=$F_VER

F_EXEC_RAW=$(grep '^Exec=' $DESKTOP  | head -n 1|sed 's/^Exec=//g'|xargs -n 1 echo|head -n 1)
F_EXEC=$(echo $F_EXEC_RAW|sed -e "s/$PKG_NAME/$LINGLONG_PKG_NAME/g" -e "s+$LINGLONG_PKG_NAME/files/usr+$LINGLONG_PKG_NAME/files+g" -e "s+^/usr+/opt/apps/$LINGLONG_PKG_NAME/files+g")

F_STARTUP=/opt/apps/$LINGLONG_PKG_NAME/files/bin/start.sh

F_DIR=$(dirname "$F_EXEC")
if [ -z "$F_DIR" ] || [ "$F_DIR" == "." ];then
  F_DIR=/opt/apps/$LINGLONG_PKG_NAME/files/bin
fi

echo ExecRaw=$F_EXEC_RAW
echo Exec=$F_EXEC
echo CWD=$F_DIR

cat >linglong.yaml <<EOF
version: "1"

package:
  id: $LINGLONG_PKG_NAME
  name: $PKG_NAME
  version: $F_VER
  kind: app
  description: |
$F_DESC

command: [$F_STARTUP]

base: org.deepin.foundation/23.0.0
runtime: org.deepin.Runtime/23.0.1

build: |
  export F_STARTUP="$F_STARTUP"
  export F_VER="$F_VER"
  export PKG_NAME="$PKG_NAME"
  export LINGLONG_PKG_NAME="$LINGLONG_PKG_NAME"
  export CWD="$CWD"
  export F_DIR="$F_DIR"
  export F_EXEC="$F_EXEC"
  export F_EXEC_RAW="$F_EXEC_RAW"
  export DESKTOP_NAME="$DESKTOP_NAME"
  bash "$ROOT/pkg-build-temp.sh"
EOF

if ll-builder build;then 
  pkg-install.sh
  # st=$(date +%s)
  # ll-builder run
  # et=$(date +%s)
  # sec=$((et-st))

  # if [ $sec -gt 10 ];then
  #   pkg-export.sh
  # fi
fi

rm -rf linglong
rm *.layer 2>/dev/null