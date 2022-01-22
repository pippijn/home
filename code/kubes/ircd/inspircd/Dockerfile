
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
 inspircd \
 openssl \
 && apt-get clean

COPY --chown=irc:irc inspircd /etc/inspircd/
COPY init.sh /
RUN touch /var/run/inspircd.pid && chown irc:irc /var/run/inspircd.pid
USER irc
WORKDIR /etc/inspircd
RUN ["openssl", "dhparam", "-out", "/etc/inspircd/dhparams.pem", "1024"]
ENTRYPOINT ["/init.sh"]
