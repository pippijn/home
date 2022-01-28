#!/bin/sh

set -eux

docker build -t xinutec/toktok .
sudo systemctl stop docker-toktok
docker run --name=toktok --rm -it \
  -p 2223:22 \
  -v $PWD/toktok-stack:/src/workspace \
  -v $HOME/.local/share/zsh/toktok:/home/builde/.local/share/zsh \
  xinutec/toktok
