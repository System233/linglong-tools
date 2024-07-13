#!/bin/bash

for i in $*;do
    pkg-install.sh $i
done
