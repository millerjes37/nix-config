#!/usr/bin/env bash
# Quick setup script for the Zsh configuration

set -e

echo "===== Quick Shell Setup ====="
echo "This script will set up the essential Zsh configuration files"
echo "without having to wait for the full home-manager switch to complete."

# Create essential configuration files
mkdir -p "$HOME/.config/zsh"

# Copy aliases file
cat > "$HOME/.zsh_aliases" << 'EOF'
# Common aliases for both platforms

# Nix-specific commands
# Rebuild the Nix configuration
nixrebuild() {
  $HOME/nix-config/scripts/rebuild.sh "$@"
}

# Run a short-lived Nix shell with specified packages
nix-shell-with() {
  nix-shell -p "$@" --run zsh
}

# Install a package with Nix
nix-install() {
  nix-env -iA "nixpkgs.$1"
}

# Search for a package in Nixpkgs
nix-search() {
  nix search nixpkgs "$@"
}

# File system navigation and listing
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Editors and tools
alias n='nvim'
alias v='nvim'
alias vim='nvim'
alias g='git'
alias d='docker'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias gp='git push'
alias gl='git log --graph --pretty=format:"%Cblue%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold cyan)<%an>%Creset"'
EOF

echo "✓ Created $HOME/.zsh_aliases"

# Create zshenv file
cat > "$HOME/.zshenv" << 'EOF'
# Auto-generated zshenv file for Nix integration

# Load Nix environment
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Add Nix paths
export PATH="$HOME/.nix-profile/bin:$PATH"
EOF

echo "✓ Created $HOME/.zshenv"

# Create basic zshrc
cat > "$HOME/.zshrc" << 'EOF'
# Generated minimal zshrc configuration

# Load aliases
if [ -f "$HOME/.zsh_aliases" ]; then
  source "$HOME/.zsh_aliases"
fi

# Basic settings
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt AUTO_CD
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY

# Basic completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Initialize zoxide if available
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# Initialize fzf if available
if [ -d ~/.nix-profile/share/fzf ]; then
  source ~/.nix-profile/share/fzf/key-bindings.zsh
  source ~/.nix-profile/share/fzf/completion.zsh
fi

# Add keybindings
bindkey -e  # Emacs keybindings

# Simple prompt
PS1='%F{green}%n@%m%f:%F{blue}%~%f$ '

# Show a message
echo "Minimal Zsh configuration loaded. Run 'home-manager switch' to load the full configuration."
EOF

echo "✓ Created $HOME/.zshrc"

echo ""
echo "Setup complete! 🎉"
echo ""
echo "To try out your new Zsh configuration, run:"
echo "  exec /home/jackson/.nix-profile/bin/zsh"
echo ""
echo "To make Zsh your default shell, run:"
echo "  ./scripts/use-nix-zsh.sh"
echo ""
echo "After the full home-manager build completes, you can use:"
echo "  nixrebuild"
echo "to update your configuration."
echo ""