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

# Make "irssi" user accessible for the VPS owner. Run this command as the
# irssi user, otherwise root may change file ownership.
if [ ! -f .ssh/authorized_keys ]; then
  echo "Copying initial home for $IRSSI_USER"
  su - irssi -c "rsync -avrP /home/$IRSSI_USER/ /home/irssi"
fi

# Start screen for "irssi" user. It's up to the user what that does exactly,
# but the default /etc/screenrc launches irssi.
su - irssi -c 'screen -d -m'

while true; do
  echo "Starting health endpoint"
  # TODO: implement actual health check
  nc -lp 2000
done
