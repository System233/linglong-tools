#!/bin/bash


for i in `ls`;do
    rm -rf $i/AppDir $i/*.layer  $i/linglong #$i/packages
done