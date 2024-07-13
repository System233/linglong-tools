#!/bin/bash

if [ -n "$1" ];then
  EXEC=`which $1||echo $1`
else
  EXEC=$(which `tail -n1 /opt/apps/*/files/bin/start.sh |xargs -n1 echo 2>/dev/null|head -n 1`)
  if echo $EXEC|grep -qF "AppRun";then
      EXEC=$(which `tail $EXEC -n1|xargs -n1 echo 2>/dev/null|head -n2|tail -n1`)
  fi
fi
ldd $EXEC 2>/dev/null|grep -F "not found"|awk -F= '{print $1}'

EXEC=$(start.sh 2>&1|grep 'loading shared libraries'|awk -F: '{print $1}')
ldd $EXEC 2>/dev/null|grep -F "not found"|awk -F= '{print $1}'
start.sh 2>&1|grep 'loading shared libraries'|awk -F: '{print $3}'