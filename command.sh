#!/usr/bin/env bash

set -eux

init_git() {
  git config --global include.path "$HOME/.dotfiles/.gitconfig"

  set +ux
  if [ -n "$GLITCH_REMOTE_URL" ]; then
    git remote add glitch "$GLITCH_REMOTE_URL"
  fi
  set -ux
}

init_ngrok() {
  set +ux
  if [ -n "$NGROK_AUTHTOKEN" ]; then
    ngrok authtoken "$NGROK_AUTHTOKEN"
  fi
  set -ux
}

init_gh() {
  set +ux
  if [ -n "$GH_AUTHTOKEN" ]; then
    gh auth login --with-token < <(echo "$GH_AUTHTOKEN")
  fi
  set -ux
}

init_navi() {
  github_user="$(echo "$GITPOD_WORKSPACE_CONTEXT" | jq -r .repository.owner)"
  remote_url="https://github.com/$github_user/cheats.git"
  target_dir="$(navi info cheats-path)/${github_user}__cheats"

  if ! git ls-remote --exit-code "$remote_url" >/dev/null 2>&1; then
    return
  fi

  if [ -d "$target_dir" ]; then
    cd "$target_dir" && git pull --ff-only origin main
  else
    git clone "$remote_url" "$target_dir"
  fi
}

init_bit() {
  set +u
  tempfile="$(mktemp)"

  trap "rm -f ""$tempfile""" ERR
  set +x

  if [ -n "$BIT_SSH_SECRET_KEY" ]; then
    eval "$(ssh-agent -s)"

    echo "$BIT_SSH_SECRET_KEY" | base64 --decode >"$tempfile"
    chmod 400 "$tempfile"
    set -x
    ssh-add "$tempfile"
    rm -f "$tempfile"
  fi

  set -ux
}

init_rclone() {
  set +ux

  config_file="$HOME/.config/rclone/rclone.conf"

  if [ ! -d "$config_file" ]; then
    mkdir -p "$(dirname "$config_file")"
  fi

  if [ -n "$RCLONE_CONFIG_CONTENTS" ]; then
    echo "$RCLONE_CONFIG_CONTENTS" | base64 --decode >"$config_file"
  fi

  set -ux
}

init_git
init_ngrok
init_gh
init_navi
init_bit
init_rclone

set +x

echo ''
echo '💡 Please execute following like'
echo '  init_code'
echo ''
