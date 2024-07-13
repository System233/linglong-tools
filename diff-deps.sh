#!/bin/bash
ROOT=$(dirname $0)
echo $@|xargs -n1 echo
$ROOT/list-deps.sh $@|grep -vxFf "$ROOT/env.deps"