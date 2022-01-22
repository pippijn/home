#!/bin/sh

set -eux

POD=$(sudo kubectl get pod -n ircd | grep '^inspircd' | awk '{print $1}')
sudo kubectl cp inspircd/conf/secret "ircd/$POD:/etc/inspircd/conf/"
sudo kubectl exec --stdin --tty -n ircd "pod/$POD" -- /bin/bash -c 'kill -HUP 1'
