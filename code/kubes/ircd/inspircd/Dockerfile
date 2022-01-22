FROM debian:bullseye-slim

ENV VERSION=3.12.0

RUN apt-get update && apt-get install -y --no-install-recommends \
 ca-certificates \
 git \
 openssl \
 wget \
 && wget "https://github.com/inspircd/inspircd/releases/download/v$VERSION/inspircd_$VERSION.deb11u1_amd64.deb" \
 && apt-get install -y --no-install-recommends "./inspircd_$VERSION.deb11u1_amd64.deb" \
 && rm "inspircd_$VERSION.deb11u1_amd64.deb" \
 && apt-get clean

# Root actions: create pid file (even though we know the pid is always going
# to be 1).
RUN touch /var/run/inspircd.pid \
 && chown irc:irc /etc/inspircd /var/run/inspircd.pid \
 && rm -rf /etc/inspircd/*

# User actions: set up git remote for config pushes and generate dhparams
# file. We're always using the most up-to-date configs, not the ones from
# the submodule in the home repo.
USER irc
WORKDIR /etc/inspircd
RUN git clone https://github.com/xinutec/inspircd /etc/inspircd \
 && git config pull.rebase true \
 && openssl dhparam -out /etc/inspircd/dhparams.pem 1024

# If we're building locally (for testing), we also copy the secrets.
# Otherwise, the secret directory is empty.
COPY --chown=irc:irc inspircd/conf/secret /etc/inspircd/conf/secret

COPY init.sh /
ENTRYPOINT ["/init.sh"]
