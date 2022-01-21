#!/bin/sh

set -eux

service ssh start

# The first time the container is started, SSH keys are generated.
if [ ! -f /etc/ssh_keys/.stamp ]; then
  # We move those to the persistent storage.
  mv /etc/ssh/ssh_host_* /etc/ssh_keys/
fi
# Then we symlink them back. If there was a .stamp file, this is not the
# first time and so we'll link the old persisted keys back.
ln -sf /etc/ssh_keys/* /etc/ssh/
touch /etc/ssh_keys/.stamp

su - irssi -c 'screen -d -m'
while true; do
  echo "Starting health endpoint"
  # TODO: implement actual health check
  nc -lp 2000
done
