#!/bin/bash

# 检查是否安装了 apt-file
if ! command -v apt-file &> /dev/null; then
    echo "apt-file 未安装。正在安装 apt-file..."
    sudo apt-get update
    sudo apt-get install -y apt-file
    sudo apt-file update
fi

echo $@|xargs -P $(nproc) -n 1 apt-file search|sort|uniq
