#!/bin/sh

set -eux

sudo kubectl get secret -n ircd irc-tls -o json | jq -r '.data."tls.crt"' | base64 -d > inspircd/conf/secret/cert.pem
sudo kubectl get secret -n ircd irc-tls -o json | jq -r '.data."tls.key"' | base64 -d > inspircd/conf/secret/key.pem

POD=$(sudo kubectl get pod -n ircd | grep '^inspircd' | awk '{print $1}')
sudo kubectl cp inspircd/conf/secret "ircd/$POD:/etc/inspircd/conf/"
sudo kubectl exec --stdin --tty -n ircd "pod/$POD" -- /bin/bash -c 'kill -HUP 1'
