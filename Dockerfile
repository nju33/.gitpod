# hadolint ignore=DL3006
FROM gitpod/workspace-full

SHELL ["/bin/bash", "-o", "pipefail"]

# Install Ngrok
RUN curl -ongrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip \
  && unzip ngrok.zip -d /usr/local/bin \
  && rm ngrok.zip

# RUN brew doctor
# RUN df -h

# Add a worker
RUN useradd -l -u 65433 -G sudo -md /workspace/nju33 -s /bin/bash -p 33AxovH1nWcQM nju33 \
  && groupadd docker \
  && usermod -aG docker nju33 \
  && usermod -aG gitpod nju33
USER nju33

# Install custom tools, runtime, etc.
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends chromium-browser libgtk-3-dev libnss3-dev expect tmux emacs rsync \
  && rm -rf /var/lib/apt/lists/*

# Apply user-specific settings
ENV NODE_OPTIONS=--max_old_space_size=4096

# Install global npm packages
# hadolint ignore=DL3016
RUN npm install --global \
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

# Install bit and set setting
RUN bvm install \
  && bit config set user.name "純" \
  && bit config set user.email "nju33.ki@gmail.com" \
  && bit config set analytics_reporting false \
  && bit config set anonymous_reporting false

WORKDIR "$HOME"

RUN git clone https://github.com/nju33/.dotfiles.git \
  && ln -s "$HOME/.dotfiles/.agignore" "$HOME/.agignore" \
  && ln -s "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf" \
  && ln -s "$HOME/.dotfiles/init.el" "$HOME/init.el" \
  && mkdir -p "$HOME/.config" \
  && ln -s "$HOME/.dotfiles/.config_starship.toml" "$HOME/.config/starship.toml"

# Install custom tools, runtime, etc.
RUN sed -i -e "/carlocab\/personal\|tophat\/bar\|azure-cli\|git-lfs\|imagemagick\|python\|ruby\|webp\|tmux\|jq\|tree\|vim\|gnupg\|nginx\|the_silver_searcher\|peco\|monolith\|ngrok\|unrar\|duf\|sed\|emacs\|yvm\|pinentry/d" .dotfiles/Brewfile \
  && brew update \
  && brew outdated \
  && brew upgrade \
  && brew cleanup \
  && brew bundle

# Install azure-cli
# RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install aws-cli
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
#   && unzip awscliv2.zip \
#   && sudo ./aws/install \
#   && rm awscliv2.zip

# Install deno
RUN asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git \
  && asdf install deno latest \
  && asdf global deno latest
# RUN curl -fsSL https://deno.land/x/install/install.sh | sh
# RUN /home/gitpod/.deno/bin/deno completions bash > /home/gitpod/.bashrc.d/90-deno && \
#   echo 'export DENO_INSTALL="/home/gitpod/.deno"' >> /home/gitpod/.bashrc.d/90-deno && \
#   echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> /home/gitpod/.bashrc.d/90-deno


# COPY --chown=gitpod:gitpod .bashrc.d/linuxbrew "$HOME/.bashrc.d/333-linuxbrew"
# COPY --chown=gitpod:gitpod .bashrc.d/pyenv "$HOME/.bashrc.d/333-pyenv"
# COPY --chown=gitpod:gitpod .bashrc.d/gpg "$HOME/.bashrc.d/333-gpg"
# COPY --chown=gitpod:gitpod .bashrc.d/thefuck "$HOME/.bashrc.d/333-thefuck"
# COPY --chown=gitpod:gitpod .bashrc.d/starship "$HOME/.bashrc.d/333-starship"
# COPY --chown=gitpod:gitpod .bashrc.d/zoxide "$HOME/.bashrc.d/333-zoxide"
# COPY --chown=gitpod:gitpod .ssh/config "$HOME/.ssh/config"

COPY --chown=nju33:nju33 .bashrc.d/linuxbrew "$HOME/.bashrc.d/333-linuxbrew"
COPY --chown=nju33:nju33 .bashrc.d/pyenv "$HOME/.bashrc.d/333-pyenv"
COPY --chown=nju33:nju33 .bashrc.d/gpg "$HOME/.bashrc.d/333-gpg"
COPY --chown=nju33:nju33 .bashrc.d/thefuck "$HOME/.bashrc.d/333-thefuck"
COPY --chown=nju33:nju33 .bashrc.d/starship "$HOME/.bashrc.d/333-starship"
COPY --chown=nju33:nju33 .bashrc.d/zoxide "$HOME/.bashrc.d/333-zoxide"
COPY --chown=nju33:nju33 .ssh/config "$HOME/.ssh/config"

# Install transfer.sh
RUN mkdir "$HOME/oss" \
  && git clone https://github.com/dutchcoders/transfer.sh.git "$HOME/oss/transfer.sh" \