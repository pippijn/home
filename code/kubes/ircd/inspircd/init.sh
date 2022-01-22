#!/bin/sh

# The first time, the secrets need to be copied into the container. After
# that, these are persisted while the shared configs are not.
while [ ! -f conf/secret/server.conf ]; do
  echo "[$(date)] Waiting for conf/secret/server.conf..."
  sleep 30
done

config_pull() {
  # Initial git ref.
  git rev-parse HEAD > /tmp/inspircd.hash

  while true; do
    # Every 5 minutes.
    sleep 300

    echo "$(date) Checking for new configs"
    git pull
    # Check whether anything changed.
    git rev-parse HEAD > /tmp/inspircd.hash.new
    diff /tmp/inspircd.hash.new /tmp/inspircd.hash || {
      mv /tmp/inspircd.hash.new /tmp/inspircd.hash
      kill -HUP $(cat /var/run/inspircd.pid)
    }
  done
}

# Initial pull on startup.
git pull
# Continuous fetch and rehash loop.
config_pull &
exec /usr/sbin/inspircd --nofork
