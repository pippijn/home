FROM toxchat/bazel:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
 gnupg \
 locales \
 openssh-server \
 screen \
 sudo \
 vim \
 zsh \
 && apt-get clean

WORKDIR /src/workspace
RUN groupadd -g 1000 user \
 && useradd -m -g user -G sudo -u 1000 -s /usr/bin/zsh user \
 && chown user:user /src/workspace \
 && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8

USER user

# Prepare user's home.
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
ENV BAZEL="sudo -i -u user bazel"

# 1. Download some required third_party packages (e.g. Android SDK).
RUN git clone https://github.com/TokTok/toktok-stack /src/workspace \
 && tools/prepare_third_party.sh
# 2. Download all other third party dependencies.
RUN rm -f tools/BUILD.bazel \
 && $BAZEL aquery --show_timestamps --output=proto //... > /dev/null \
 && git checkout tools/BUILD.bazel
# 3. Build //third_party in default (fastbuild) mode. Use remote here and in
#    the initial build, but not later when `user` is interactively working.
RUN cp .bazelrc.local.example .bazelrc.local \
 && $BAZEL build --show_timestamps --config=remote //third_party/...
# 4. Download the submodules and build them once.
RUN git submodule update --init --recursive \
 && $BAZEL build --show_timestamps --config=remote -- //... -//echobot-jvm/...

# Add user's extra configs.
COPY --chown=user:user home /home/

USER root
COPY etc /etc
RUN echo 'AuthorizedKeysFile .ssh/authorized_keys /etc/ssh/authorized_keys' >> /etc/ssh/sshd_config \
 && chmod 644 /etc/screenrc \
 && mkdir /etc/ssh_keys 
COPY init.sh /
ENTRYPOINT ["/init.sh"]
