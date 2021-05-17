#!/usr/bin/env bash

set -eux

init_gpg() {
  set +ux
  if [ -n "$GPG_SECRET_KEY" ]; then
    gpg --batch --import --allow-secret-key-import <(echo "$GPG_SECRET_KEY" | base64 --decode)
  fi
  set -ux
}

init_git_around_gpg() {
  set +ux
  git config --global user.signingkey "$GIT_USER_SIGNINGKEY"
  set -ux
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true
}

init_zoxide() {
  if [ -d "$GITPOD_REPO_ROOT/.gitpod/zoxide" ] && [ -f "$GITPOD_REPO_ROOT/.gitpod/zoxide/db.zo" ]; then
    if [ ! -d "$HOME/.local/share/zoxide" ]; then
      mkdir -p "$HOME/.local/share/zoxide"
    fi

    cp "$GITPOD_REPO_ROOT/.gitpod/zoxide/db.zo" "$HOME/.local/share/zoxide/"
  fi
}

init_gpg
init_git_around_gpg
init_zoxide
