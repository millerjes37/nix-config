#!/usr/bin/env bash
set -e

# Script to check if required tools are installed
# Consolidates functionality from check-commands.sh

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_CONFIG_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Define tool categories
ESSENTIAL_TOOLS=(
  "eza"
  "bat"
  "fd"
  "rg"
  "dust"
  "procs"
  "btm"
  "tldr"
  "nvim"
  "sd"
  "zoxide"
  "jq"
  "difft"
  "delta"
)

WINDOW_MANAGER_TOOLS=(
  "yabai"
  "skhd"
)

NIX_TOOLS=(
  "nix"
  "home-manager"
  "nixos-rebuild"
)

# Check tools in a category
function check_tools_category() {
  local category_name=$1
  shift
  local tools=("$@")
  
  print_header "CHECKING ${category_name} TOOLS"
  
  for tool in "${tools[@]}"; do
    check_command "$tool"
  done
  
  echo
}

# Check if Nix profile exists and is properly set up
function check_nix_profile() {
  print_header "CHECKING NIX PROFILE"
  
  echo "Your Nix profile is at: $HOME/.nix-profile"
  if [ -d "$HOME/.nix-profile/bin" ]; then
    print_success "Nix profile bin directory exists"
    
    # List nix profile binaries
    echo "--- First 10 commands in Nix profile ---"
    ls -la $HOME/.nix-profile/bin | head -n 10
  else
    print_error "Nix profile bin directory doesn't exist"
  fi
  
  echo
}

# Print PATH
function print_path() {
  print_header "PATH VARIABLE"
  echo $PATH | tr ":" "\n"
  echo
}

# Print ZSH configurations
function print_zsh_info() {
  print_header "ZSH CONFIGURATION"
  
  if [ -f "$HOME/.zshrc" ]; then
    print_success "Found .zshrc file"
  else
    print_warning "No .zshrc file found"
  fi
  
  if [ -f "$HOME/.zshrc-custom" ]; then
    print_success "Found .zshrc-custom file"
    echo "To use the custom ZSH configuration, run:"
    echo "source ~/.zshrc-custom"
  else
    print_warning "No .zshrc-custom file found"
  fi
  
  if [ -f "$HOME/.p10k.zsh" ]; then
    print_success "Found Powerlevel10k configuration"
  else
    print_warning "No Powerlevel10k configuration found"
  fi
  
  echo
}

# Main function
function main() {
  print_header "SYSTEM TOOLS CHECK"
  
  # Check all tool categories
  check_tools_category "ESSENTIAL" "${ESSENTIAL_TOOLS[@]}"
  check_tools_category "WINDOW MANAGER" "${WINDOW_MANAGER_TOOLS[@]}"
  check_tools_category "NIX" "${NIX_TOOLS[@]}"
  
  # Check Nix profile
  check_nix_profile
  
  # Print PATH
  print_path
  
  # Print ZSH info
  print_zsh_info
  
  print_header "SYSTEM CHECK COMPLETE"
}

# Run the script
main