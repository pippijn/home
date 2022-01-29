#!/bin/sh

set -eux

docker build -t xinutec/toktok -f workspace/tools/built/Dockerfile .
sudo systemctl restart docker-toktok
sudo journalctl -f -u docker-toktok
