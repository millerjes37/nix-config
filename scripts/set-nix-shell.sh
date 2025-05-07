#!/usr/bin/env bash
# Script to set the Nix-defined shell as the default shell

set -e

# Get the Nix Zsh path
NIX_ZSH=$(which zsh)

if [[ -z "$NIX_ZSH" ]]; then
  echo "Error: Zsh not found in Nix profile. Please make sure it's installed."
  exit 1
fi

echo "Found Nix Zsh at: $NIX_ZSH"

# Check if the shell is already in /etc/shells
if grep -q "^$NIX_ZSH$" /etc/shells; then
  echo "✓ $NIX_ZSH is already in /etc/shells"
else
  echo "Adding $NIX_ZSH to /etc/shells (requires sudo)..."
  sudo sh -c "echo $NIX_ZSH >> /etc/shells"
  echo "✓ Added $NIX_ZSH to /etc/shells"
fi

# Check if it's already the default shell
if [[ "$SHELL" == "$NIX_ZSH" ]]; then
  echo "✓ $NIX_ZSH is already your default shell"
else
  echo "Changing your shell to $NIX_ZSH..."
  chsh -s "$NIX_ZSH"
  echo "✓ Shell changed to $NIX_ZSH"
  echo "Please log out and log back in for the change to take effect."
fi

# Check if zsh config exists
ZSH_FUNCTIONS="$HOME/.zsh_functions"
if [[ ! -f "$ZSH_FUNCTIONS" ]]; then
  echo "Warning: $ZSH_FUNCTIONS does not exist. You may need to run home-manager switch."
fi

P10K_CONFIG="$HOME/.p10k.zsh"
if [[ ! -f "$P10K_CONFIG" ]]; then
  echo "Warning: $P10K_CONFIG does not exist. You may need to run home-manager switch."
fi

echo ""
echo "Setup complete! 🎉"
echo "To apply your Nix configuration, run:"
echo "  cd ~/nix-config && ./scripts/rebuild.sh"
echo ""