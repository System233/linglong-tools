#!/bin/bash


ROOT=$(readlink -f $(dirname $0))

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ROOT/lib

strace -f $@ 2>&1