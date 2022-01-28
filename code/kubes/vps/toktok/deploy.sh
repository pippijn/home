#!/bin/sh

set -eux

docker build -t xinutec/toktok .
sudo systemctl restart docker-toktok
sudo journalctl -f -u docker-toktok
