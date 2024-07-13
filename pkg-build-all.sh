#!/bin/bash
EXPORT_DIR=/media/sf_VMShared

# for i in $*;do
#     PKG_NAME=$(echo "$i"|sed 's/.linyaps$//g')
#     LINGLONG_PKG_NAME="${PKG_NAME}.linyaps"
#     if [ ! -e $EXPORT_DIR/$LINGLONG_PKG_NAME*_runtime.layer ];then
#         echo Building $PKG_NAME
#         mkdir -p $LINGLONG_PKG_NAME 2>/dev/null
#         pkg-build.sh $PKG_NAME &>$LINGLONG_PKG_NAME/output.log &
#         sleep 15
#     else
#         echo Skip $PKG_NAME
#     fi
# done

MAX_JOBS=$(nproc)
MAX_JOBS=3 #$((MAX_JOBS/2))
JOBS=0

function build(){
    PKG_NAME=$(echo "$1"|sed 's/.linyaps$//g')
    LINGLONG_PKG_NAME="${PKG_NAME}.linyaps"
    if [ ! -e $EXPORT_DIR/$LINGLONG_PKG_NAME*_runtime.layer ];then
        echo Building $PKG_NAME
        mkdir -p $LINGLONG_PKG_NAME 2>/dev/null
        pkg-build.sh $PKG_NAME < /dev/null &>$LINGLONG_PKG_NAME/output.log
        echo Finish $PKG_NAME code=$?
        # sleep 5
    else
        echo Skip $PKG_NAME
    fi
}

for i in $*;do
    # build $i
    while [ "$JOBS" -ge "$MAX_JOBS" ]; do
        wait -n
        JOBS=$((JOBS-1))
    done

    build $i &

    JOBS=$((JOBS+1))
done
