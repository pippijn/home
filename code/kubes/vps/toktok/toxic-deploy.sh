#!/bin/sh

set -eux

ssh toktok -t 'cd /src/workspace && bazel build --config=debug --config=linux-arm64-musl //toxic'
scp toktok:/src/workspace/bazel-bin/toxic/toxic .
ssh hermes.vpn 'rm toxic'
scp toxic hermes.vpn:
rm toxic
