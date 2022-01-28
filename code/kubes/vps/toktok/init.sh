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

if grep "BEGIN" ~builder/key.pem; then
  sudo -i -u builder gpg --import ~builder/key.pem
fi

# Re-initialise third party and git remotes if this is an external volume
# mounted the first time.
if [ ! -d third_party/android/sdk ]; then
  tools/prepare_third_party.sh
  tools/git-remotes
fi

sudo -i -u builder bazel build //...

exec netcat -l 0.0.0.0 2000
