#!/bin/sh

while [ ! -f conf/secret/server.conf ]; do
  echo "[$(date)] Waiting for conf/secret/server.conf..."
  sleep 30
done
exec /usr/sbin/inspircd --config inspircd.conf --logfile /dev/stderr --nofork
