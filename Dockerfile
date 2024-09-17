# hadolint ignore=DL3006
FROM gitpod/workspace-full

USER root
WORKDIR /tmp

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install custom tools, runtime, etc.
# Memos
# - Google Chrome depend on fonts-liberation and xdg-utils
# - Remotion depends on ffmpeg
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    chromium-browser \
    libgtk-3-dev \
    libnss3-dev \
    expect \
    fuse \
    tmux \
    emacs \
    rsync \
    ffmpeg \
    fonts-liberation \
    xdg-utils \
    libvulkan1 \
  && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  && dpkg -i google-chrome-stable_current_amd64.deb \
  && apt-get install -f -y --no-install-recommends \
  && rm google-chrome-stable_current_amd64.deb

USER gitpod
ENV GITPOD_HOME "$HOME"
WORKDIR "$HOME"

RUN git clone https://github.com/nju33/.dotfiles.git \
  && ln -s "$GITPOD_HOME/.dotfiles/.agignore" "$GITPOD_HOME/.agignore" \
  && ln -s "$GITPOD_HOME/.dotfiles/.tmux.conf" "$GITPOD_HOME/.tmux.conf" \
  && ln -s "$GITPOD_HOME/.dotfiles/init.el" "$GITPOD_HOME/init.el" \
  && mkdir -p "$GITPOD_HOME/.config" \
  && ln -s "$GITPOD_HOME/.dotfiles/.config_starship.toml" "$GITPOD_HOME/.config/starship.toml"

# Install fonts
COPY fonts/ /tmp/
RUN mkdir -p "$HOME/.local/share/fonts/notosansjp" \
  && unzip -d "$HOME/.local/share/fonts/notosansjp" /tmp/notosansjp.zip \
  && mkdir -p "$HOME/.local/share/fonts/azuki_font" \
  && unzip -d "$HOME/.local/share/fonts/azuki_font" /tmp/azuki_font.zip \
  && fc-cache -f

# Install custom tools, runtime, etc.
RUN sed -i -e "/carlocab\/personal\|tophat\/bar\|azure-cli\|git-lfs\|imagemagick\|python\|ruby\|webp\|tmux\|jq\|tree\|vim\|gnupg\|nginx\|the_silver_searcher\|peco\|monolith\|ngrok\|unrar\|duf\|sed\|emacs\|yvm\|pinentry\|1password-cli/d" .dotfiles/Brewfile \
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

# Install nodejs
RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
  && asdf install nodejs latest \
  && asdf global nodejs latest

# Install deno
RUN asdf plugin add deno https://github.com/asdf-community/asdf-deno.git \
  && asdf install deno latest \
  && asdf global deno latest

# Install gcloud
RUN asdf plugin add gcloud https://github.com/jthegedus/asdf-gcloud.git \
  && asdf install gcloud latest \
  && asdf global gcloud latest

# Install PostgreSQL
#
# Usage:
# 1. Create the .tool-versions file in the current directory:
#    `echo "postgres $(psql --version | awk '{print $NF}')" > .tool-versions`
# 2. Start PostgreSQL:
#    `pg_ctl start`
# 3. Create a default database (replace 'default' with your desired database name):
#    `createdb -U postgres default`
# 4. Connect to the default database:
#    `psql -U postgres -d default`
# 5. To stop PostgreSQL:
#    `pg_ctl stop`
RUN asdf plugin add postgres https://github.com/smashedtoatoms/asdf-postgres.git \
  && asdf install postgres latest \
  && asdf global postgres latest

# Apply user-specific settings
ENV NODE_OPTIONS=--max_old_space_size=4096

# Install global npm packages
# hadolint ignore=SC1091,DL3016
RUN \
  . "$(brew --prefix asdf)/libexec/asdf.sh" \
  && npm install --location=global \
    @google/clasp `# https://github.com/google/clasp#readme` \
    npm-check-updates \
    npm \
    vercel \
  && npm cache clean --force