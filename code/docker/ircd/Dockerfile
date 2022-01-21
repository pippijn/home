# We're using buster, the last Debian that has InspIRCd 2.0.
FROM debian:buster-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
 ca-certificates \
 curl \
 g++ \
 inspircd \
 inspircd-dev \
 && apt-get clean

# Build the SSL rehash module.
RUN curl -s -o m_rehashsslsignal.cpp https://raw.githubusercontent.com/inspircd/inspircd-contrib/master/2.0/m_rehashsslsignal.cpp \
 && g++ -fPIC -shared -I/usr/include/inspircd -o m_rehashsslsignal.so m_rehashsslsignal.cpp

FROM debian:buster-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
 inspircd \
 openssl \
 && apt-get clean

COPY --from=build /m_rehashsslsignal.so /usr/lib/inspircd/modules/
COPY --chown=irc:irc inspircd /etc/inspircd/
COPY init.sh /
RUN touch /var/run/inspircd.pid && chown irc:irc /var/run/inspircd.pid
USER irc
WORKDIR /etc/inspircd
RUN ["openssl", "dhparam", "-out", "/etc/inspircd/dhparams.pem", "1024"]
ENTRYPOINT ["/init.sh"]
