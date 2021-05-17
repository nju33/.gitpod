#!/usr/bin/env bash

set -eux

init_js_workspace() {
  local pkg_file="$GITPOD_REPO_ROOT/package.json"
  local yarn_lock_file="$GITPOD_REPO_ROOT/yarn.lock"
  local pkg_lock_file="$GITPOD_REPO_ROOT/package-lock.json"

  if [ -f "$pkg_file" ]; then
    # Install dependencies
    if [ -f "$yarn_lock_file" ]; then
      yarn
    elif [ -f "$pkg_lock_file" ]; then
      npm ci
    fi
  fi
}

init_js_workspace
