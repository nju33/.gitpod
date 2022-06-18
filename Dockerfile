# hadolint ignore=DL3006
FROM gitpod/workspace-full

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install custom tools, runtime, etc.
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends chromium-browser libgtk-3-dev libnss3-dev expect fuse tmux emacs rsync \
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
  && brew update \
  && brew outdated \
  && brew upgrade \
  && brew cleanup \
  && brew bundle --file .dotfiles/Brewfile

COPY --chown=gitpod:gitpod ".bashrc.d/asdf" "$GITPOD_HOME/.bashrc.d/333-asdf"
COPY --chown=gitpod:gitpod ".bashrc.d/linuxbrew" "$GITPOD_HOME/.bashrc.d/333-linuxbrew"
COPY --chown=gitpod:gitpod ".bashrc.d/npm" "$GITPOD_HOME/.bashrc.d/333-npm"
COPY --chown=gitpod:gitpod ".bashrc.d/home-bin" "$GITPOD_HOME/.bashrc.d/333-home-bin"
COPY --chown=gitpod:gitpod ".bashrc.d/pyenv" "$GITPOD_HOME/.bashrc.d/333-pyenv"
COPY --chown=gitpod:gitpod ".bashrc.d/gpg" "$GITPOD_HOME/.bashrc.d/333-gpg"
COPY --chown=gitpod:gitpod ".bashrc.d/thefuck" "$GITPOD_HOME/.bashrc.d/333-thefuck"
COPY --chown=gitpod:gitpod ".bashrc.d/starship" "$GITPOD_HOME/.bashrc.d/333-starship"
COPY --chown=gitpod:gitpod ".bashrc.d/zoxide" "$GITPOD_HOME/.bashrc.d/333-zoxide"
COPY --chown=gitpod:gitpod ".ssh/config" "$GITPOD_HOME/.ssh/config"
COPY --chown=gitpod:gitpod "rc/.npmrc" "$GITPOD_HOME/.npmrc"
COPY --chown=gitpod:gitpod "rc/.yarnrc.yml" "$GITPOD_HOME/.yarnrc.yml"

###################################
#! I'm saving this one for someday.
#! 
#! Footprints for memory: https://github.com/nju33/.gitpod/commit/2b90e31dee28c061b4a2ca3776d9fe8517fda9c7
###################################
# USER root
# # Add a worker
# RUN useradd -l -u 65433 -g gitpod -G sudo -md /workspace/nju33 -s /bin/bash -p 33AxovH1nWcQM nju33 \
#   && groupadd docker \
#   && usermod -aG docker nju33
#
# USER nju33
# ENV NJU33_HOME "/workspace/nju33"
# ENV HOME "/workspace/nju33"
# WORKDIR "$HOME"
# RUN : \
#   && id \
#   && pwd \
#   && sudo rsync -a \
#     --chown "$(id -u):$(id -g)" \
#     `# For getting a dirname that end with /` \
#     "$(dirname "${GITPOD_HOME}/meaningless_directory")/" \
#     "$NJU33_HOME"
#
## Grant write permission to the gitpod group
# RUN sudo chmod -R g+w /home/linuxbrew
# RUN git config --global --add safe.directory /home/linuxbrew/.linuxbrew/Homebrew
#   && git -C "/home/linuxbrew/.linuxbrew/Homebrew" remote add origin https://github.com/Homebrew/brew

# Install nodejs
RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
  && asdf install nodejs latest:16 \
  && asdf global nodejs latest:16

# Install deno
RUN asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git \
  && asdf install deno latest:1 \
  && asdf global deno latest:1

# Install gcloud
RUN asdf plugin-add gcloud https://github.com/jthegedus/asdf-gcloud \
  && asdf install gcloud latest \
  && asdf global gcloud latest

# TODO: Fix `No space left on device`
# They may be a good solution
# 1. Do this in the .gitpod.Dockerfile
# 2. Do this in the before.sh of Gitpod's task
#
# Install postgres
#
# Usage
# 1. Create the .tool-versions on a current directory
#.   `echo "postgres $(psql --version | awk '{print $NF}')" > .tool-versions`
# 2. `pg_ctl strt`
# 3. `createdb -U postgres default` (the default is a database name)
# 4. `psql -U postgres -d default`
# n. To stop by `pg_ctl stop`
RUN asdf plugin-add postgres https://github.com/smashedtoatoms/asdf-postgres \
  && asdf install postgres latest \
  && asdf global postgres latest

# Apply user-specific settings
ENV NODE_OPTIONS=--max_old_space_size=4096
# Install global npm packages
# hadolint ignore=DL3016
RUN \
  . "$(brew --prefix asdf)/libexec/asdf.sh" \
  && npm install --location=global \
    `# https://github.com/google/clasp#readme` \
    @google/clasp \
    `# https://github.com/teambit/bvm#readme` \
    @teambit/bvm \
    `# https://github.com/sgentle/caniuse-cmd#readme` \
    caniuse-cmd \
    npm-check-updates \
    npm \
    pageres-cli \
    tldr \
    vercel \
  && npm cache clean --force \
  `# Cache pages into $HOME/.tldr/` \
  && PATH="$(asdf where nodejs)/.npm/bin:$PATH" tldr --update

# Install bit and set setting
RUN PATH="$(asdf where nodejs)/.npm/bin:$PATH" bvm install \
  && "$HOME/bin/bit" config set user.name "純" \
  && "$HOME/bin/bit" config set user.email "nju33.ki@gmail.com" \
  && "$HOME/bin/bit" config set analytics_reporting false \
  && "$HOME/bin/bit" config set anonymous_reporting false

# Install azure-cli
# RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# ^ This might be replaced by using following asdf's plugin
#   `azure-cli https://github.com/itspngu/asdf-azure-cli.git`

# Install aws-cli
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
#   && unzip awscliv2.zip \
#   && sudo ./aws/install \
#   && rm awscliv2.zip
# ^ This might be replaced by using following asdf's plugin
#   `awscli https://github.com/MetricMike/asdf-awscli.git`

# Install transfer.sh
RUN mkdir "$HOME/oss" \
  && git clone https://github.com/dutchcoders/transfer.sh.git "$HOME/oss/transfer.sh" \
