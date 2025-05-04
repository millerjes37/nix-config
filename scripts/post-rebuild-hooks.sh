#!/usr/bin/env bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Path to the nix-config directory
NIX_CONFIG_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Window Manager Setup
function setup_window_managers() {
  echo -e "\n${BLUE}Setting up window managers...${NC}"
  
  # Check if window manager setup script exists
  if [[ -f "$NIX_CONFIG_DIR/scripts/install-window-managers.sh" ]]; then
    # Run the window manager setup script
    echo -e "${YELLOW}Running window manager setup script...${NC}"
    "$NIX_CONFIG_DIR/scripts/install-window-managers.sh"
    echo -e "${GREEN}Window managers set up successfully!${NC}"
  else
    echo -e "${RED}Window manager setup script not found.${NC}"
    echo -e "${YELLOW}Skipping window manager setup.${NC}"
  fi
}

# Main function
function main() {
  echo -e "${BLUE}====== RUNNING POST-REBUILD HOOKS ======${NC}"
  
  # Check if window managers are enabled in configuration
  if grep -q "programs.yabai.enable\s*=\s*false" "$NIX_CONFIG_DIR/home.nix" && \
     grep -q "programs.skhd.enable\s*=\s*false" "$NIX_CONFIG_DIR/home.nix"; then
    # Window managers are externally managed, set them up
    setup_window_managers
  else
    echo -e "${YELLOW}Window managers are managed by Nix/Home Manager. Skipping external setup.${NC}"
  fi
  
  echo -e "\n${BLUE}====== POST-REBUILD HOOKS COMPLETE ======${NC}"
}

# Run the main function
main