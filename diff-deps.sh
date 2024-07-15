#!/bin/bash
ROOT=$(dirname $0)
echo $@|xargs -n1 echo
ENV_DEPS="$ROOT/env.rt.deps"
if [ -n $NO_RT_ENV ];then
    ENV_DEPS="$ROOT/env.nrt.deps"
fi
$ROOT/list-deps.sh $@|grep -vxFf "${ENV_DEPS}"