FROM gitpod/workspace-full

# Install custom tools, runtime, etc.
RUN sudo apt-get update \
  && sudo apt-get install -y chromium-browser libgtk-3-dev libnss3-dev expect tmux emacs \
  && sudo rm -rf /var/lib/apt/lists/*

# Apply user-specific settings
ENV NODE_OPTIONS=--max_old_space_size=4096

RUN npm install --global @google/clasp @teambit/bvm caniuse-cmd npm-check-updates npm-home npm pageres-cli tldr vercel \
  && npm cache clean --force
RUN bvm install

WORKDIR "$HOME"
RUN git clone https://github.com/nju33/.dotfiles.git \
  && cd .dotfiles \
  && ln -s "$(pwd)/.bash_aliases" "$HOME/.bash_aliases" \
  && ln -s "$(pwd)/.agignore" "$HOME/.agignore" \
  && ln -s "$(pwd)/.tmux.conf" "$HOME/.tmux.conf" \
  && ln -s "$(pwd)/init.el" "$HOME/init.el" \
  && mkdir -p "$HOME/.config" && ln -s "$(pwd)/.config_starship.toml" "$HOME/.config/starship.toml"
  
RUN curl -ongrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip \
  && sudo unzip ngrok.zip -d /usr/local/bin \
  && rm ngrok.zip
  
# Install azure-cli
# RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install aws-cli
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
#   && unzip awscliv2.zip \
#   && sudo ./aws/install \
#   && rm awscliv2.zip

# Install transfer.sh
RUN git clone https://github.com/dutchcoders/transfer.sh.git ~/oss/transfer.sh

# RUN brew doctor
# Install custom tools, runtime, etc.
RUN df -h
RUN cd .dotfiles \
  && sed -i -e "/carlocab\/personal\|tophat\/bar\|azure-cli\|git-lfs\|imagemagick\|python\|ruby\|webp\|tmux\|jq\|tree\|vim\|gnupg\|nginx\|the_silver_searcher\|peco\|monolith\|ngrok\|unrar\|duf\|sed\|emacs\|yvm/d" Brewfile \
  && brew update \
  && brew outdated \
  && brew upgrade \
  && brew cleanup \
  && brew bundle

COPY --chown=gitpod:gitpod .gitpod/.bashrc.d/gpg "$HOME/.bashrc.d/333-gpg"
COPY --chown=gitpod:gitpod .gitpod/.bashrc.d/thefuck "$HOME/.bashrc.d/333-thefuck"
COPY --chown=gitpod:gitpod .gitpod/.bashrc.d/starship "$HOME/.bashrc.d/333-starship"
COPY --chown=gitpod:gitpod .gitpod/.bashrc.d/code "$HOME/.bashrc.d/333-code"
COPY --chown=gitpod:gitpod .gitpod/.bashrc.d/zoxide "$HOME/.bashrc.d/333-zoxide"
COPY --chown=gitpod:gitpod .gitpod/extensions/wdhongtw.gpg-indicator-0.3.4.vsix "$HOME/wdhongtw.gpg-indicator-0.3.4.vsix"

