FROM toxchat/toktok-stack:latest

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
 gnupg \
 locales \
 netcat \
 openssh-server \
 screen \
 sudo \
 vim \
 zsh \
 && apt-get clean

RUN usermod -G sudo -s /usr/bin/zsh builder \
 && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8

USER builder

# Prepare builder's home.
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
 && sed -i \
 -e 's/^ZSH_THEME=.*/ZSH_THEME="cypher"/' \
 -e 's/^# HYPHEN_INSENSITIVE/HYPHEN_INSENSITIVE/' \
 -e 's/^# COMPLETION_WAITING_DOTS/COMPLETION_WAITING_DOTS/' \
 "$HOME/.zshrc" \
 && echo "export CC=$CC" > "$HOME/.zprofile" \
 && echo "export CXX=$CXX" >> "$HOME/.zprofile" \
 && echo "cd /src/workspace" >> "$HOME/.zprofile"

# Use "sudo -i" to run bazel in the exact same environment that will later be
# used by the user logged in via ssh.
ENV BAZEL="sudo -i -u builder bazel"

COPY --chown=builder:builder toktok-stack /src/workspace/

# 1. Build everything in default (fastbuild) mode. Use remote here in the
#    initial build, but not later when `builder` is interactively working.
RUN cp .bazelrc.local.example .bazelrc.local \
 && $BAZEL build --show_timestamps --config=remote -- //... -//echobot-jvm/...

# Add builder's configs.
COPY --chown=builder:builder home /home/

USER root
ENTRYPOINT ["/init.sh"]
