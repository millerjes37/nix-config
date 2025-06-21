#!/usr/bin/env bash
# Script: setup-shell.sh
# Purpose: Post-install helper to finish Home-Manager setup in a single run
#          (similar to DHH's one-command installer).
#
# Actions performed (requires sudo):
#   1. Ensure the Home-Manager-provided zsh is listed in /etc/shells.
#   2. Change the current user's login shell to that zsh.
#   3. Optionally create handy system-wide symlinks to profile binaries
#      (Cursor, Home-Manager, etc.).
#
# Usage:
#   sudo ./scripts/setup-shell.sh  [--user username] [--link] [--dry-run]
#
#   --user   Username to fix (defaults to $SUDO_USER or $USER)
#   --link   Create /usr/local/bin symlinks for a few common tools.
#   --dry-run  Show what would be done without making changes.
#
set -euo pipefail

# ---------- helper -----------------
info()  { echo -e "\033[1;32m==> $*\033[0m"; }
warn()  { echo -e "\033[1;33m[WARN] $*\033[0m"; }
err()   { echo -e "\033[1;31m[ERROR] $*\033[0m" >&2; }

dry_run=false
make_links=false
TARGET_USER="${SUDO_USER:-$USER}"

while [[ $# -gt 0 ]]; do
  case $1 in
    --user) TARGET_USER="$2"; shift 2;;
    --link) make_links=true; shift;;
    --dry-run) dry_run=true; shift;;
    *) err "Unknown flag $1"; exit 1;;
  esac
done

HOME_DIR=$(eval echo "~${TARGET_USER}")
PROFILE="$HOME_DIR/.nix-profile"
ZSH_PATH="$PROFILE/bin/zsh"

if [[ ! -x "$ZSH_PATH" ]]; then
  err "$ZSH_PATH not found or not executable. Make sure Home-Manager is activated first."; exit 1
fi

# Step 1: ensure /etc/shells contains the path
if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
  info "Adding $ZSH_PATH to /etc/shells"
  $dry_run || echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
else
  info "$ZSH_PATH already present in /etc/shells"
fi

# Step 2: change login shell if necessary
CURRENT_SHELL=$(getent passwd "$TARGET_USER" | cut -d: -f7)
if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
  info "Changing login shell for $TARGET_USER to $ZSH_PATH"
  $dry_run || sudo chsh -s "$ZSH_PATH" "$TARGET_USER"
else
  info "Login shell for $TARGET_USER already set to zsh"
fi

# Step 3: optional symlinks
if $make_links; then
  for bin in code-cursor home-manager; do
    src="$PROFILE/bin/$bin"
    dest="/usr/local/bin/$bin"
    if [[ -x "$src" ]]; then
      if [[ -L "$dest" ]]; then
        info "Symlink $dest already exists – skipping."
      else
        info "Creating symlink $dest -> $src"
        $dry_run || sudo ln -s "$src" "$dest"
      fi
    else
      warn "$src not found – skip link."
    fi
  done
fi

info "Done. Log out and back in to start using zsh." 