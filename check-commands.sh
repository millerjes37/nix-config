#!/bin/bash

# Script to check if key commands are available
echo "Checking for command availability:"

# Function to check if a command exists
check_command() {
  if command -v "$1" &> /dev/null; then
    echo "✅ $1 is available at: $(which $1)"
  else
    echo "❌ $1 is not available"
  fi
}

# Check for essential commands
echo "--- Essential Commands ---"
check_command eza
check_command bat
check_command fd
check_command rg
check_command dust
check_command procs
check_command btm
check_command tldr
check_command nvim
check_command sd
check_command zoxide
check_command jq
check_command difft
check_command delta

# Check Nix profile path
echo
echo "--- Nix Path Check ---"
echo "Your Nix profile is at: $HOME/.nix-profile"
if [ -d "$HOME/.nix-profile/bin" ]; then
  echo "✅ Nix profile bin directory exists"
  
  # List nix profile binaries
  echo "--- First 10 commands in Nix profile ---"
  ls -la $HOME/.nix-profile/bin | head -n 10
else
  echo "❌ Nix profile bin directory doesn't exist"
fi

# Print PATH
echo
echo "--- PATH Variable ---"
echo $PATH | tr ":" "\n"

echo
echo "To use the custom ZSH configuration, run:"
echo "source ~/.zshrc-custom"