#!/bin/sh

set -eux

docker build -t xinutec/toktok -f workspace/tools/built/Dockerfile .
exec docker run --name=toktok-dev --rm -it \
  -p 2224:22 \
  -v "$PWD/workspace:/src/workspace" \
  -v "$HOME/.local/share/zsh/toktok:/home/builder/.local/share/zsh" \
  xinutec/toktok
