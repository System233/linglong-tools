#!/bin/bash

chmod +x ~/.local/bin/*.sh
tee -a ~/.bashrc <<EOF
export PATH=\$PATH:~/.local/bin

alias "llb=ll-builder build"
alias "llr=ll-builder run"
alias "llbe=ll-builder build --exec bash"
alias "llre=ll-builder run --exec bash"

alias "lle=ll-builder export"

alias "llcr=ll-cli run"
alias "llci=ll-cli install"
alias "llcu=ll-cli uninstall"
alias "llcl=ll-cli list"
alias "llcp=ll-cli ps"

EOF