#!/usr/bin/zsh

# Any user zsh settings go here.
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=$HOME/.local/share/zsh/history

export CC=/usr/local/bin/clang
export CXX=/usr/local/bin/clang++
cd /src/workspace

export PATH="$PATH:/src/workspace/hs-github-tools/tools"

alias gs=gst
