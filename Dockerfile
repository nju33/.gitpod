# hadolint ignore=DL3006
FROM gitpod/workspace-full

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install custom tools, runtime, etc.
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends chromium-browser libgtk-3-dev libnss3-dev expect tmux emacs rsync \
  && rm -rf /var/lib/apt/lists/*

# Install Ngrok
RUN curl -ongrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip \
  && unzip ngrok.zip -d /usr/local/bin \
  && rm ngrok.zip

# RUN brew doctor
# RUN df -h

USER gitpod

RUN git clone https://github.com/nju33/.dotfiles.git \
  && ln -s "$HOME/.dotfiles/.agignore" "$HOME/.agignore" \
  && ln -s "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf" \
  && ln -s "$HOME/.dotfiles/init.el" "$HOME/init.el" \
  && mkdir -p "$HOME/.config" \
  && ln -s "$HOME/.dotfiles/.config_starship.toml" "$HOME/.config/starship.toml"

# Install custom tools, runtime, etc.
RUN sed -i -e "/carlocab\/personal\|tophat\/bar\|azure-cli\|git-lfs\|imagemagick\|python\|ruby\|webp\|tmux\|jq\|tree\|vim\|gnupg\|nginx\|the_silver_searcher\|peco\|monolith\|ngrok\|unrar\|duf\|sed\|emacs\|yvm\|pinentry/d" .dotfiles/Brewfile \
  # && brew doctor \
  && brew update \
  && brew outdated \
  && brew upgrade \
  && brew cleanup \
  && brew bundle --file .dotfiles/Brewfile

USER root

# Add a worker
RUN useradd -l -u 65433 -G sudo -md /workspace/nju33 -s /bin/bash -p 33AxovH1nWcQM nju33 \
  && groupadd docker \
  && usermod -aG docker nju33 \
  && usermod -aG gitpod nju33

USER nju33
ENV GITPOD_HOME "$HOME"
ENV NJU33_HOME "/workspace/nju33"
ENV HOME "/workspace/nju33"
WORKDIR "$HOME"
RUN whoami && pwd

# RUN git clone https://github.com/nju33/.dotfiles.git \
#   && ln -s "$HOME/.dotfiles/.agignore" "$HOME/.agignore" \
#   && ln -s "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf" \
#   && ln -s "$HOME/.dotfiles/init.el" "$HOME/init.el" \
#   && mkdir -p "$HOME/.config" \
#   && ln -s "$HOME/.dotfiles/.config_starship.toml" "$HOME/.config/starship.toml"

# Grant write permission to the gitpod group
# RUN sudo chmod -R g+w /home/linuxbrew

# RUN git config --global --add safe.directory /home/linuxbrew/.linuxbrew/Homebrew
  # && git -C "/home/linuxbrew/.linuxbrew/Homebrew" remote add origin https://github.com/Homebrew/brew

# Install custom tools, runtime, etc.
# RUN sed -i -e "/carlocab\/personal\|tophat\/bar\|azure-cli\|git-lfs\|imagemagick\|python\|ruby\|webp\|tmux\|jq\|tree\|vim\|gnupg\|nginx\|the_silver_searcher\|peco\|monolith\|ngrok\|unrar\|duf\|sed\|emacs\|yvm\|pinentry/d" .dotfiles/Brewfile \
#   # && git -C "/home/linuxbrew/.linuxbrew/Homebrew" remote add origin https://github.com/Homebrew/brew \
#   # `# fatal: unsafe repository ('/home/linuxbrew/.linuxbrew/Homebrew' is owned by someone else)` \
#   # `# To add an exception for this directory, call:` \
#   # && git config --global --add safe.directory /home/linuxbrew/.linuxbrew/Homebrew \
#   # && brew doctor \
#   && brew update \
#   && brew outdated \
#   && brew upgrade \
#   && brew cleanup \
#   && brew bundle --file .dotfiles/Brewfile

# Apply user-specific settings
ENV NODE_OPTIONS=--max_old_space_size=4096

# Install nodejs
RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
  && asdf install nodejs latest:16 \
  && asdf global nodejs latest:16

# Install deno
RUN asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git \
  && asdf install deno latest:1 \
  && asdf global deno latest:1

# Asdf paths are given top priority
ENV PATH "$NJU33_HOME/.asdf/shims:$NJU33_HOME/bin:$PATH"

# Install global npm packages
# hadolint ignore=DL3016
RUN \
  which npm \
  && npm install --location=global \
    `# https://github.com/google/clasp#readme` \
    @google/clasp \
    `# https://github.com/teambit/bvm#readme` \
    @teambit/bvm \
    `# https://github.com/sgentle/caniuse-cmd#readme` \
    caniuse-cmd \
    npm-check-updates \
    npm-home \
    npm \
    pageres-cli \
    tldr \
    vercel \
  && npm cache clean --force

RUN df -h
# Install bit and set setting
RUN "$(npm --global bin)/bvm" install
# RUN ls -al "$HOME/bin"
RUN bit config set user.name "純" \
  && bit config set user.email "nju33.ki@gmail.com" \
  && bit config set analytics_reporting false \
  && bit config set anonymous_reporting false

# Install azure-cli
# RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install aws-cli
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
#   && unzip awscliv2.zip \
#   && sudo ./aws/install \
#   && rm awscliv2.zip

# Install deno
# RUN asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git \
#   && asdf install deno latest \
#   && asdf global deno latest
# RUN curl -fsSL https://deno.land/x/install/install.sh | sh
# RUN /home/gitpod/.deno/bin/deno completions bash > /home/gitpod/.bashrc.d/90-deno && \
#   echo 'export DENO_INSTALL="/home/gitpod/.deno"' >> /home/gitpod/.bashrc.d/90-deno && \
#   echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> /home/gitpod/.bashrc.d/90-deno


COPY --chown=gitpod:gitpod ".bashrc.d/linuxbrew" "$GITPOD_HOME/.bashrc.d/333-linuxbrew"
COPY --chown=gitpod:gitpod ".bashrc.d/pyenv" "$GITPOD_HOME/.bashrc.d/333-pyenv"
COPY --chown=gitpod:gitpod ".bashrc.d/gpg" "$GITPOD_HOME/.bashrc.d/333-gpg"
COPY --chown=gitpod:gitpod ".bashrc.d/thefuck" "$GITPOD_HOME/.bashrc.d/333-thefuck"
COPY --chown=gitpod:gitpod ".bashrc.d/starship" "$GITPOD_HOME/.bashrc.d/333-starship"
COPY --chown=gitpod:gitpod ".bashrc.d/zoxide" "$GITPOD_HOME/.bashrc.d/333-zoxide"
COPY --chown=gitpod:gitpod ".ssh/config" "$GITPOD_HOME/.ssh/config"
COPY --chown=nju33:nju33 ".bashrc.d/linuxbrew" "$NJU33_HOME/.bashrc.d/333-linuxbrew"
COPY --chown=nju33:nju33 ".bashrc.d/pyenv" "$NJU33_HOME/.bashrc.d/333-pyenv"
COPY --chown=nju33:nju33 ".bashrc.d/gpg" "$NJU33_HOME/.bashrc.d/333-gpg"
COPY --chown=nju33:nju33 ".bashrc.d/thefuck" "$NJU33_HOME/.bashrc.d/333-thefuck"
COPY --chown=nju33:nju33 ".bashrc.d/starship" "$NJU33_HOME/.bashrc.d/333-starship"
COPY --chown=nju33:nju33 ".bashrc.d/zoxide" "$NJU33_HOME/.bashrc.d/333-zoxide"
COPY --chown=nju33:nju33 ".ssh/config" "$NJU33_HOME/.ssh/config"

# Install transfer.sh
RUN mkdir "$HOME/oss" \
  && git clone https://github.com/dutchcoders/transfer.sh.git "$HOME/oss/transfer.sh" \

# RUN : \
#   && sudo cp "$GITPOD_HOME/.bash_history" "$NJU33_HOME" \
#   && sudo cp "$GITPOD_HOME/.bash_logout" "$NJU33_HOME" \
#   && sudo cp "$GITPOD_HOME/.bash_profile" "$NJU33_HOME" \
#   && sudo cp "$GITPOD_HOME/.bash_history" "$NJU33_HOME" \