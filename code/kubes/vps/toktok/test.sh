#!/bin/sh

set -eux

docker build -t xinutec/toktok -f workspace/tools/built/Dockerfile .
sudo systemctl stop docker-toktok
exec docker run --name=toktok --rm -it \
  -p 2223:22 \
  -v $PWD/toktok-stack:/src/workspace \
  -v $HOME/.local/share/zsh/toktok:/home/builder/.local/share/zsh \
  xinutec/toktok
