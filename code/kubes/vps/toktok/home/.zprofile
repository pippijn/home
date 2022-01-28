#!/usr/bin/zsh

# Any user zsh settings go here.
HISTFILE=$HOME/.local/share/zsh/history
HISTSIZE=1000000
SAVEHIST=1000000

CASE_SENSITIVE=true
COMPLETION_WAITING_DOTS=true
HYPHEN_INSENSITIVE=true

export CC=/usr/local/bin/clang
export CXX=/usr/local/bin/clang++

export PATH="$PATH:/src/workspace/hs-github-tools/tools"

alias gs=gst
alias gsr="git ss"

cd /src/workspace
