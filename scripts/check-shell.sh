#!/usr/bin/env bash
# Script to check the status of shell configuration

set -e

echo "===== Checking Shell Configuration ====="

# 1. Check current shell
CURRENT_SHELL=$(basename "$SHELL")
echo "Current shell: $CURRENT_SHELL"
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
  echo "✓ Using Zsh"
else
  echo "⚠️  Not using Zsh yet. To test Zsh without changing default shell, run: exec zsh"
fi

# 2. Check for Nix-managed zsh
NIX_ZSH=$(which zsh 2>/dev/null || echo "not found")
if [[ "$NIX_ZSH" == *".nix-profile"* ]]; then
  echo "✓ Found Nix-managed Zsh: $NIX_ZSH"
else
  echo "⚠️  Nix-managed Zsh not found in PATH"
fi

# 3. Check for configuration files
echo -e "\nChecking configuration files:"
CONFIG_FILES=(
  "$HOME/.zshrc"
  "$HOME/.zsh_aliases"
  "$HOME/.zsh_functions"
  "$HOME/.p10k.zsh"
  "$HOME/.zshenv"
  "$HOME/.bash_profile"
)

for file in "${CONFIG_FILES[@]}"; do
  if [[ -f "$file" ]]; then
    echo "✓ Found $file"
  else
    echo "⚠️  Missing $file"
  fi
done

# 4. Check for nixrebuild function
echo -e "\nChecking for nixrebuild:"
if [[ -f "$HOME/.zsh_aliases" ]] && grep -q "nixrebuild()" "$HOME/.zsh_aliases"; then
  echo "✓ nixrebuild function found in .zsh_aliases"
else
  echo "⚠️  nixrebuild function not found in .zsh_aliases"
fi

# 5. Check Nix configuration
echo -e "\nChecking Nix configuration:"
if [[ -d "$HOME/nix-config" ]]; then
  echo "✓ Found nix-config directory"
  if [[ -x "$HOME/nix-config/scripts/rebuild.sh" ]]; then
    echo "✓ Found executable rebuild.sh script"
  else
    echo "⚠️  rebuild.sh not found or not executable"
  fi
else
  echo "⚠️  nix-config directory not found"
fi

# 6. Suggest next steps
echo -e "\n===== Next Steps ====="
echo "To ensure everything is properly configured:"

if [[ "$CURRENT_SHELL" != "zsh" ]]; then
  echo "1. Switch to Zsh by running: exec $NIX_ZSH"
  echo "2. After switching, build your configuration: cd ~/nix-config && ./scripts/rebuild.sh"
else
  echo "1. Build your configuration: cd ~/nix-config && ./scripts/rebuild.sh"
  echo "2. Verify aliases by running: alias | grep nixrebuild"
fi

echo "3. For a permanent switch to Zsh, run: ~/nix-config/scripts/use-nix-zsh.sh"
echo "4. Logout and login again to ensure changes take effect"
echo ""