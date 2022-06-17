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
ENV GITPOD_HOME "$HOME"

RUN git clone https://github.com/nju33/.dotfiles.git \
  && ln -s "$GITPOD_HOME/.dotfiles/.agignore" "$GITPOD_HOME/.agignore" \
  && ln -s "$GITPOD_HOME/.dotfiles/.tmux.conf" "$GITPOD_HOME/.tmux.conf" \
  && ln -s "$GITPOD_HOME/.dotfiles/init.el" "$GITPOD_HOME/init.el" \
  && mkdir -p "$GITPOD_HOME/.config" \
  && ln -s "$GITPOD_HOME/.dotfiles/.config_starship.toml" "$GITPOD_HOME/.config/starship.toml"

# Install custom tools, runtime, etc.
RUN sed -i -e "/carlocab\/personal\|tophat\/bar\|azure-cli\|git-lfs\|imagemagick\|python\|ruby\|webp\|tmux\|jq\|tree\|vim\|gnupg\|nginx\|the_silver_searcher\|peco\|monolith\|ngrok\|unrar\|duf\|sed\|emacs\|yvm\|pinentry/d" .dotfiles/Brewfile \
  # && brew doctor \
  && brew update \
  && brew outdated \
  && brew upgrade \
  && brew cleanup \
  && brew bundle --file .dotfiles/Brewfile

COPY --chown=gitpod:gitpod ".bashrc.d/linuxbrew" "$GITPOD_HOME/.bashrc.d/333-linuxbrew"
COPY --chown=gitpod:gitpod ".bashrc.d/pyenv" "$GITPOD_HOME/.bashrc.d/333-pyenv"
COPY --chown=gitpod:gitpod ".bashrc.d/gpg" "$GITPOD_HOME/.bashrc.d/333-gpg"
COPY --chown=gitpod:gitpod ".bashrc.d/thefuck" "$GITPOD_HOME/.bashrc.d/333-thefuck"
COPY --chown=gitpod:gitpod ".bashrc.d/starship" "$GITPOD_HOME/.bashrc.d/333-starship"
COPY --chown=gitpod:gitpod ".bashrc.d/zoxide" "$GITPOD_HOME/.bashrc.d/333-zoxide"
COPY --chown=gitpod:gitpod ".ssh/config" "$GITPOD_HOME/.ssh/config"

USER root

# Add a worker
RUN useradd -l -u 65433 -g gitpod -G sudo -md /workspace/nju33 -s /bin/bash -p 33AxovH1nWcQM nju33 \
  && groupadd docker \
  && usermod -aG docker nju33

USER nju33
ENV NJU33_HOME "/workspace/nju33"
ENV HOME "/workspace/nju33"
WORKDIR "$HOME"
RUN : \
  && id \
  && pwd \
  && sudo rsync -a \
    --chown "$(id -u):$(id -g)" \
    `# For getting a dirname that end with /` \
    "$(dirname "${GITPOD_HOME}/meaningless_directory")/" \
    "$NJU33_HOME"

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

# RUN df -h
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

# Install transfer.sh
RUN mkdir "$HOME/oss" \
  && git clone https://github.com/dutchcoders/transfer.sh.git "$HOME/oss/transfer.sh" \

# RUN : \
#   && sudo cp "$GITPOD_HOME/.bash_history" "$NJU33_HOME" \
#   && sudo cp "$GITPOD_HOME/.bash_logout" "$NJU33_HOME" \
#   && sudo cp "$GITPOD_HOME/.bash_profile" "$NJU33_HOME" \
#   && sudo cp "$GITPOD_HOME/.bash_history" "$NJU33_HOME" \

RUN sudo chmod -R g+w /home/linuxbrew
